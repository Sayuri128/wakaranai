import 'package:wakaranai/env.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/repositories/database/tracker_link_repository.dart';
import 'package:wakaranai/services/incognito/incognito_mode.dart';
import 'package:wakaranai/services/trackers/anilist_tracker.dart';
import 'package:wakaranai/services/trackers/mal_tracker.dart';
import 'package:wakaranai/services/trackers/shikimori_tracker.dart';
import 'package:wakaranai/services/trackers/tracker_accounts_store.dart';
import 'package:wakaranai/services/trackers/tracker_models.dart';
import 'package:wakaranai/services/trackers/tracker_progress.dart';
import 'package:wakaranai/services/trackers/tracker_service.dart';

class TrackerSyncService {
  TrackerSyncService({
    required this.links,
    required this.accounts,
    required List<TrackerService> services,
    DateTime Function()? clock,
  })  : services = <TrackerId, TrackerService>{
          for (final TrackerService service in services)
            if (service.isConfigured) service.id: service,
        },
        _clock = clock ?? DateTime.now;

  factory TrackerSyncService.fromEnv({required TrackerLinkRepository links}) {
    return TrackerSyncService(
      links: links,
      accounts: SecureTrackerAccountsStore(),
      services: <TrackerService>[
        AniListTracker(clientId: Env.anilistClientId),
        ShikimoriTracker(
          clientId: Env.shikimoriClientId,
          clientSecret: Env.shikimoriClientSecret,
        ),
        MalTracker(clientId: Env.malClientId),
      ],
    );
  }

  final TrackerLinkRepository links;
  final TrackerAccountsStore accounts;
  final Map<TrackerId, TrackerService> services;
  final DateTime Function() _clock;

  List<TrackerService> get available => services.values.toList(growable: false);

  Future<TrackerAccount?> account(TrackerId id) async {
    final TrackerService? service = services[id];
    final TrackerAccount? stored = await accounts.read(id);
    if (service == null || stored == null) {
      return null;
    }
    if (!stored.isExpired(_clock())) {
      return stored;
    }
    try {
      final TrackerAccount refreshed = await service.refresh(stored);
      await accounts.write(id, refreshed);
      return refreshed;
    } catch (error) {
      logger.w('Could not refresh the ${id.name} session: $error');
      return null;
    }
  }

  Future<Map<TrackerId, TrackerAccount>> loggedIn() async {
    final Map<TrackerId, TrackerAccount> result = <TrackerId, TrackerAccount>{};
    for (final TrackerId id in services.keys) {
      final TrackerAccount? stored = await accounts.read(id);
      if (stored != null) {
        result[id] = stored;
      }
    }
    return result;
  }

  Future<TrackerAccount> login(TrackerId id) async {
    final TrackerService service = _service(id);
    final TrackerAccount account = await service.login();
    await accounts.write(id, account);
    return account;
  }

  Future<void> logout(TrackerId id) async {
    await accounts.remove(id);
    await links.removeAllFor(id);
  }

  Future<List<TrackerSearchResult>> search(
    TrackerId id,
    String query,
    TrackerMediaType type,
  ) async {
    final TrackerAccount account = await _requireAccount(id);
    return _service(id).search(account, query, type);
  }

  Future<TrackerLink> link({
    required TrackerId trackerId,
    required String concreteUid,
    required String extensionUid,
    required TrackerMediaType type,
    required TrackerSearchResult result,
    int? localProgress,
  }) async {
    final TrackerService service = _service(trackerId);
    final TrackerAccount account = await _requireAccount(trackerId);
    TrackerEntry? entry = await service.entry(account, result.remoteId, type);
    final int local = localProgress ?? 0;
    if (entry == null || (!IncognitoMode.active && local > entry.progress)) {
      entry = await service.update(
        account,
        result.remoteId,
        type,
        status: statusAfterProgress(
          current: entry?.status ?? TrackerStatus.current,
          progress: local,
          totalCount: result.totalCount,
        ),
        progress: local,
      );
    }
    final TrackerLink link = TrackerLink(
      concreteUid: concreteUid,
      trackerId: trackerId,
      extensionUid: extensionUid,
      mediaType: type,
      remoteId: result.remoteId,
      remoteTitle: result.title,
      status: entry.status,
      progress: entry.progress,
      totalCount: entry.totalCount ?? result.totalCount,
      syncedAt: _clock(),
    );
    await links.save(link);
    return link;
  }

  Future<List<TrackerLink>> linkOthersByMalId({
    required TrackerId origin,
    required String concreteUid,
    required String extensionUid,
    required TrackerMediaType type,
    required int malId,
    int? localProgress,
  }) async {
    final Set<TrackerId> already = (await links.linksFor(concreteUid))
        .map((TrackerLink link) => link.trackerId)
        .toSet();
    final List<TrackerLink> linked = <TrackerLink>[];
    for (final TrackerId id in services.keys) {
      if (id == origin || already.contains(id)) {
        continue;
      }
      final TrackerAccount? current = await account(id);
      if (current == null) {
        continue;
      }
      try {
        final int? remoteId = await _remoteIdForMal(id, current, malId, type);
        if (remoteId == null) {
          continue;
        }
        final TrackerSearchResult? result =
            await _service(id).byId(current, remoteId, type);
        if (result == null) {
          continue;
        }
        linked.add(await link(
          trackerId: id,
          concreteUid: concreteUid,
          extensionUid: extensionUid,
          type: type,
          result: result,
          localProgress: localProgress,
        ));
      } catch (error) {
        logger.w('Could not link ${id.name} through MAL id $malId: $error');
      }
    }
    return linked;
  }

  Future<void> unlink(String concreteUid, TrackerId trackerId) {
    return links.remove(concreteUid, trackerId);
  }

  Future<TrackerLink> setStatus(TrackerLink link, TrackerStatus status) {
    return _push(link, progress: link.progress, status: status);
  }

  Future<TrackerLink> setProgress(TrackerLink link, int progress) {
    return _push(
      link,
      progress: progress,
      status: statusAfterProgress(
        current: link.status,
        progress: progress,
        totalCount: link.totalCount,
      ),
    );
  }

  Future<void> recordProgress(String concreteUid, int? progress) async {
    if (progress == null || progress <= 0 || IncognitoMode.active) {
      return;
    }
    for (final TrackerLink link in await links.linksFor(concreteUid)) {
      if (progress <= link.progress) {
        continue;
      }
      await _push(
        link,
        progress: progress,
        status: statusAfterProgress(
          current: link.status,
          progress: progress,
          totalCount: link.totalCount,
        ),
      );
    }
  }

  Future<int> retryPending() async {
    int pushed = 0;
    for (final TrackerLink link in await links.pending()) {
      final int? pending = link.pendingProgress;
      if (pending == null || pending <= link.progress) {
        await links.save(link.copyWith(pendingProgress: () => null));
        continue;
      }
      final TrackerLink updated = await _push(
        link,
        progress: pending,
        status: statusAfterProgress(
          current: link.status,
          progress: pending,
          totalCount: link.totalCount,
        ),
      );
      if (updated.pendingProgress == null) {
        pushed++;
      }
    }
    return pushed;
  }

  Future<TrackerLink> _push(
    TrackerLink link, {
    required int progress,
    required TrackerStatus status,
  }) async {
    final TrackerService? service = services[link.trackerId];
    final TrackerAccount? current = await account(link.trackerId);
    if (service == null || current == null) {
      final TrackerLink pending = link.copyWith(pendingProgress: () => progress);
      await links.save(pending);
      return pending;
    }
    try {
      final TrackerEntry entry = await service.update(
        current,
        link.remoteId,
        link.mediaType,
        status: status,
        progress: progress,
      );
      final TrackerLink updated = link.copyWith(
        status: entry.status,
        progress: entry.progress,
        totalCount: entry.totalCount,
        pendingProgress: () => null,
        syncedAt: _clock(),
      );
      await links.save(updated);
      return updated;
    } catch (error) {
      logger.w('Tracker ${link.trackerId.name} update failed: $error');
      final TrackerLink pending = link.copyWith(pendingProgress: () => progress);
      await links.save(pending);
      return pending;
    }
  }

  Future<int?> _remoteIdForMal(
    TrackerId id,
    TrackerAccount current,
    int malId,
    TrackerMediaType type,
  ) async {
    if (id == TrackerId.mal || id == TrackerId.shikimori) {
      return malId;
    }
    final TrackerService service = _service(id);
    if (service is AniListTracker) {
      return service.idForMalId(current, malId, type);
    }
    return null;
  }

  TrackerService _service(TrackerId id) {
    final TrackerService? service = services[id];
    if (service == null) {
      throw TrackerAuthException('${id.name} is not configured');
    }
    return service;
  }

  Future<TrackerAccount> _requireAccount(TrackerId id) async {
    final TrackerAccount? current = await account(id);
    if (current == null) {
      throw TrackerAuthException('Not signed in to ${id.name}');
    }
    return current;
  }
}
