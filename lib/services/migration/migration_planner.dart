import 'package:capyscript/api_clients/api_client.dart';
import 'package:capyscript/modules/waka_models/models/common/concrete_view.dart';
import 'package:capyscript/modules/waka_models/models/common/gallery_view.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:wakaranai/database/wakaranai_database.dart';
import 'package:wakaranai/services/migration/migration_models.dart';
import 'package:wakaranai/services/migration/migration_progress.dart';
import 'package:wakaranai/services/migration/migration_store.dart';
import 'package:wakaranai/utils/serial_call_queue.dart';

class MigrationCandidate {
  const MigrationCandidate({
    required this.client,
    required this.config,
    required this.item,
    this.coverHeaders = const <String, String>{},
  });

  final ApiClient client;
  final ConfigInfo config;
  final GalleryView item;
  final Map<String, String> coverHeaders;

  String get key => '${config.uid}::${item.uid}';
}

class MigrationPreparation {
  const MigrationPreparation({
    required this.subject,
    required this.target,
    required this.progress,
    required this.trackerLinks,
    required this.downloads,
    required this.categoryId,
  });

  final MigrationSubject subject;
  final MigrationTarget target;
  final MigrationProgressPlan progress;
  final int trackerLinks;
  final int downloads;
  final int? categoryId;

  MigrationRequest request(MigrationOptions options) {
    return MigrationRequest(
      subject: subject,
      target: target,
      progress: progress,
      options: options,
    );
  }
}

typedef ConcreteLoader = Future<ConcreteView> Function(
  MigrationCandidate candidate,
);

Future<ConcreteView> _fetchConcrete(MigrationCandidate candidate) {
  final ApiClient client = candidate.client;
  return runSerializedOn<ConcreteView>(
    client,
    () => client.getConcrete(
      uid: candidate.item.uid,
      data: candidate.item.data,
    ),
  );
}

class MigrationPlanner {
  MigrationPlanner({required this.store, ConcreteLoader? loadConcrete})
      : _loadConcrete = loadConcrete ?? _fetchConcrete;

  final MigrationStore store;
  final ConcreteLoader _loadConcrete;

  Future<MigrationSubject> complete(MigrationSubject subject) async {
    final List<String> saved = await store.loadAlternativeTitles(subject.uid);
    final List<String> titles = <String>[
      ...subject.alternativeTitles,
      ...saved,
    ];
    MigrationSubject completed = subject.copyWith(alternativeTitles: titles);
    if (subject.title.trim().isEmpty || subject.cover == null) {
      final ConcreteDataTableData? cached =
          await store.savedConcrete(subject.uid);
      if (cached != null) {
        completed = completed.copyWith(
          title: subject.title.trim().isEmpty ? cached.title : null,
          cover: subject.cover ?? cached.cover,
        );
      }
    }
    return completed;
  }

  Future<MigrationPreparation> prepare(
    MigrationSubject subject,
    MigrationCandidate candidate,
  ) async {
    final ConcreteView concrete = await _loadConcrete(candidate);
    final MigrationMediaKind kind = migrationKindOf(candidate.config.type);
    final List<MigrationOldProgress> oldProgress =
        await store.loadOldProgress(subject.uid, kind);
    return MigrationPreparation(
      subject: subject,
      target: MigrationTarget(
        concrete: concrete,
        config: candidate.config,
        galleryData: candidate.item.data,
      ),
      progress: mapMigrationProgress(
        kind: kind,
        progress: oldProgress,
        targetGroups: migrationTargetGroupsOf(concrete, kind),
      ),
      trackerLinks: await store.countTrackerLinks(subject.uid),
      downloads: await store.countDownloads(subject.uid),
      categoryId: await store.categoryOf(subject.uid),
    );
  }

  Future<MigrationResult> apply(
    MigrationPreparation preparation,
    MigrationOptions options,
  ) {
    return store.apply(preparation.request(options));
  }
}
