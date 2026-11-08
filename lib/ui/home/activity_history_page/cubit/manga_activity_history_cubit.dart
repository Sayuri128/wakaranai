import 'dart:async';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:wakaranai/utils/image_headers.dart';
import 'package:wakaranai/services/configs_service/api_client_factory.dart';
import 'package:wakaranai/data/domain/database/base_activity_domain.dart';
import 'package:wakaranai/data/domain/database/chapter_activity_domain.dart';
import 'package:wakaranai/data/domain/database/concrete_data_domain.dart';
import 'package:wakaranai/data/domain/database/extension_domain.dart';
import 'package:wakaranai/data/domain/ui/activity_list_item.dart';
import 'package:wakaranai/database/wakaranai_database.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/repositories/database/chapter_activity_repository.dart';
import 'package:wakaranai/repositories/database/concerete_data_repository.dart';
import 'package:wakaranai/repositories/database/extension_repository.dart';
import 'package:wakaranai/services/local_source/local_books_source.dart';
import 'package:wakaranai/services/local_source/local_sources.dart';
import 'package:wakaranai/ui/home/activity_history_page/cubit/activity_history_cubit_mixin.dart';
import 'package:wakaranai/ui/routes.dart';
import 'package:wakaranai/ui/services/manga/manga_service_viewer/concrete_viewer/manga_concrete_viewer.dart';
import 'package:wakaranai/ui/services/manga/manga_service_viewer/manga_service_viewer.dart';
import 'package:wakaranai/ui/services/novel/novel_concrete_viewer.dart';
import 'package:wakaranai/ui/services/novel/novel_service_viewer.dart';
import 'package:wakaranai/ui/widgets/snackbars.dart';

part 'manga_activity_history_state.dart';

class MangaActivityHistoryCubit extends Cubit<ActivityHistoryState>
    with ActivityHistoryCubitMixin<ChapterActivityDomain> {
  MangaActivityHistoryCubit({
    required this.extensionRepository,
    required this.concreteDataRepository,
    required this.chapterActivityRepository,
  }) : super(ActivityHistoryInitial());

  final ExtensionRepository extensionRepository;
  final ConcreteDataRepository concreteDataRepository;
  final ChapterActivityRepository chapterActivityRepository;

  void init({bool silent = false}) async {
    if (!silent) {
      emit(ActivityHistoryLoading());
    }

    try {
      final data =
          await chapterActivityRepository.getAll(orderBy: getOrderingTerms());

      final Map<int, ConcreteDataDomain> chapterActivities =
          await fetchConcretes(
              concreteIds: data.map((e) => e.concreteId).toSet(),
              concreteDataRepository: concreteDataRepository);

      emit(
        ActivityHistoryLoaded(
          mangaActivities: createActivityListItems(
            data: data,
            activities: chapterActivities,
            getConcreteId: (activity) => activity.concreteId,
          ),
          novelExtensionUids: await _novelExtensionUids(),
        ),
      );
    } catch (e) {
      emit(
        ActivityHistoryError(
          S.current.activity_history_error_loading_history,
        ),
      );
    }
  }

  Future<Set<String>> _novelExtensionUids() async {
    final List<ExtensionDomain> extensions = await extensionRepository.getAll();
    return <String>{
      LocalBooksSource.uid,
      for (final ExtensionDomain extension in extensions)
        if (extension.config.type == ConfigInfoType.NOVEL) extension.config.uid,
    };
  }

  void onDelete({
    required BuildContext context,
    required BaseActivityDomain activity,
  }) async {
    await chapterActivityRepository.deleteBy<$ChapterActivityTableTable>(
        activity.id,
        where: (tbl) => tbl.id);

    if (state is ActivityHistoryLoaded) {
      final loadedState = state as ActivityHistoryLoaded;
      final List<ActivityListItem<ChapterActivityDomain>> copy =
          List.from(loadedState.mangaActivities);
      emit(
        ActivityHistoryLoaded(
          mangaActivities: removeActivityListItem(copy, activity.uid),
          novelExtensionUids: loadedState.novelExtensionUids,
        ),
      );
    }

    SnackBars.showSnackBar(
        context: context, message: S.current.activity_history_deleted_activity);
  }

  void onActivityTap(
    BuildContext context, {
    required ConcreteDataDomain concrete,
    required BaseActivityDomain activity,
  }) async {
    final ExtensionDomain? extension =
        LocalSources.extensionFor(concrete.extensionUid) ??
            await extensionRepository.getByUid(concrete.extensionUid);
    if (extension == null) {
      SnackBars.showErrorSnackBar(
        context: context,
        error: S.current.activity_history_error_loading_history,
      );
      return;
    }

    if (extension.config.type == ConfigInfoType.NOVEL) {
      await _openNovel(context, concrete: concrete, extension: extension);
      return;
    }

    final apiClient = ApiClientFactory.instance
        .manga(config: extension.config, code: extension.sourceCode);

    final coverHeaders = await apiClient.imageHeadersOrEmpty(
      uid: concrete.uid,
      data: concrete.dataJson,
    );

    unawaited(Navigator.of(context)
        .pushNamed(
      Routes.mangaServiceViewer,
      arguments: MangaServiceViewData(
        remoteConfig: extension,
        nextViewerData: MangaConcreteViewerData(
          uid: concrete.uid,
          galleryData: concrete.dataJson,
          coverHeaders: coverHeaders,
          client: apiClient,
          configInfo: extension.config,
          galleryCover: concrete.cover,
        ),
      ),
    )
        .then((_) {
      init();
    }));
  }

  Future<void> _openNovel(
    BuildContext context, {
    required ConcreteDataDomain concrete,
    required ExtensionDomain extension,
  }) async {
    final apiClient = ApiClientFactory.instance
        .novel(config: extension.config, code: extension.sourceCode);

    final Map<String, String> coverHeaders = await apiClient.imageHeadersOrEmpty(
      uid: concrete.uid,
      data: concrete.dataJson,
    );
    if (!context.mounted) {
      return;
    }

    unawaited(Navigator.of(context)
        .pushNamed(
      Routes.novelServiceViewer,
      arguments: NovelServiceViewData(
        remoteConfig: extension,
        nextViewerData: NovelConcreteViewerData(
          uid: concrete.uid,
          galleryData: concrete.dataJson,
          coverHeaders: coverHeaders,
          client: apiClient,
          configInfo: extension.config,
          galleryCover: concrete.cover,
        ),
      ),
    )
        .then((_) {
      init();
    }));
  }
}
