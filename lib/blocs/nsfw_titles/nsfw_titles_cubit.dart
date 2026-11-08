import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakaranai/data/domain/database/base_extension.dart';
import 'package:wakaranai/data/domain/database/extension_domain.dart';
import 'package:wakaranai/repositories/database/extension_repository.dart';
import 'package:wakaranai/ui/home/configs_page/bloc/remote_configs/remote_configs_cubit.dart';

class NsfwTitlesState {
  const NsfwTitlesState({
    this.hideTitles = false,
    this.nsfwExtensionUids = const <String>{},
  });

  final bool hideTitles;
  final Set<String> nsfwExtensionUids;

  bool hides(String extensionUid) {
    return hideTitles && nsfwExtensionUids.contains(extensionUid);
  }

  NsfwTitlesState copyWith({bool? hideTitles, Set<String>? nsfwExtensionUids}) {
    return NsfwTitlesState(
      hideTitles: hideTitles ?? this.hideTitles,
      nsfwExtensionUids: nsfwExtensionUids ?? this.nsfwExtensionUids,
    );
  }
}

class NsfwTitlesCubit extends Cubit<NsfwTitlesState> {
  NsfwTitlesCubit({
    required this.extensionRepository,
    RemoteConfigsCubit? remoteConfigs,
  })  : _remoteConfigs = remoteConfigs,
        super(const NsfwTitlesState());

  static const String hideTitlesKey = 'HIDE_NSFW_TITLES';

  final ExtensionRepository extensionRepository;
  final RemoteConfigsCubit? _remoteConfigs;
  StreamSubscription<RemoteConfigsState>? _listingSubscription;

  Future<void> init() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final bool hideTitles = preferences.getBool(hideTitlesKey) ?? false;
    if (isClosed) {
      return;
    }
    emit(state.copyWith(hideTitles: hideTitles));
    _listingSubscription = _remoteConfigs?.stream.listen((_) {
      unawaited(refreshSources());
    });
    await refreshSources();
  }

  Future<void> setHideTitles(bool value) async {
    emit(state.copyWith(hideTitles: value));
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setBool(hideTitlesKey, value);
    if (value) {
      await refreshSources();
    }
  }

  Future<void> refreshSources() async {
    final Set<String> uids = <String>{};
    for (final ExtensionDomain extension in await extensionRepository.getAll()) {
      if (extension.config.nsfw) {
        uids.add(extension.config.uid);
      }
    }
    final RemoteConfigsState? listing = _remoteConfigs?.state;
    if (listing is RemoteConfigsLoaded) {
      final Iterable<BaseExtension> listed = <BaseExtension>[
        ...listing.mangaRemoteConfigs,
        ...listing.animeRemoteConfigs,
        ...listing.novelRemoteConfigs,
      ];
      for (final BaseExtension extension in listed) {
        if (extension.config.nsfw) {
          uids.add(extension.config.uid);
        }
      }
    }
    if (isClosed) {
      return;
    }
    emit(state.copyWith(nsfwExtensionUids: Set<String>.unmodifiable(uids)));
  }

  @override
  Future<void> close() async {
    await _listingSubscription?.cancel();
    return super.close();
  }
}
