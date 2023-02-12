import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/model/services/local_api_sources_service.dart';
import 'package:wakaranai/models/data/library_item.dart';
import 'package:wakaranai/models/data/local_api_client.dart';
import 'package:wakaranai/models/data/local_gallery_view.dart';
import 'package:wakaranai/ui/anime_concrete_viewer/anime_concrete_viewer.dart';
import 'package:wakaranai/ui/home/home_view.dart';
import 'package:wakaranai/ui/home/library/cubit/library_page_cubit.dart';
import 'package:wakaranai/ui/home/library/library_card.dart';
import 'package:wakaranai/ui/manga_service_viewer/concrete_viewer/manga_concrete_viewer.dart';
import 'package:wakaranai/ui/routes.dart';
import 'package:wakaranai/utils/app_colors.dart';

class LibraryPage extends StatelessWidget {
  LibraryPage({Key? key}) : super(key: key);

  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: BlocBuilder<LibraryPageCubit, LibraryPageState>(
        builder: (context, state) {
          if (state is LibraryPageLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          } else if (state is LibraryPageLoaded) {
            return PageView(controller: _pageController, children: [
              _buildPage(context, state.mangaItem, LocalApiClientType.MANGA),
              _buildPage(context, state.animeItems, LocalApiClientType.ANIME),
            ]);
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildPage(
      BuildContext context, List<LibraryItem> items, LocalApiClientType type) {
    return RefreshIndicator(
      onRefresh: () {
        return Future.delayed(
          const Duration(milliseconds: 100),
          () {
            context.read<LibraryPageCubit>().reloadPage(type);
          },
        );
      },
      color: AppColors.primary,
      backgroundColor: AppColors.backgroundColor,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: LibraryCard.aspectRatio,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8),
        itemBuilder: (context, index) {
          final item = items[index];

          // TODO: create api client in isolate to prevent ui from freezes
          // TODO: save concrete views as well and do updates only on demand
          switch (item.type) {
            case LocalApiClientType.ANIME:
              final localAnimeGalleryView =
                  item.localGalleryView as LocalAnimeGalleryView;
              return LibraryCard(
                uid: localAnimeGalleryView.uid,
                cover: localAnimeGalleryView.cover,
                title: localAnimeGalleryView.title,
                onLongPress: () {
                  showOkCancelAlertDialog(
                          context: context,
                          title: S.current
                              .gallery_view_anime_item_delete_from_library_confirmation_title(
                                  localAnimeGalleryView.title),
                          okLabel: S.current
                              .gallery_view_anime_item_delete_from_library_confirmation_ok_label,
                          cancelLabel: S.current
                              .gallery_view_anime_item_delete_from_library_confirmation_cancel_label)
                      .then((value) {
                    if (value == OkCancelResult.ok) {
                      context.read<LibraryPageCubit>().delete(item, () {
                        showNotificationSnackBar(
                            context,
                            S.current
                                .gallery_view_anime_item_deleted_from_library_notification(
                                    localAnimeGalleryView.title));
                      });
                    }
                  });
                },
                onTap: () {
                  LocalApiSourcesService.instance
                      .get(item.localApiClientId)
                      .then((value) {
                    Navigator.of(context).pushNamed(Routes.animeConcreteViewer,
                        arguments: AnimeConcreteViewerData(
                            client: value.toApiClient(),
                            uid: localAnimeGalleryView.uid,
                            galleryView: localAnimeGalleryView.asGalleryView(),
                            configInfo: value.localConfigInfo.asConfigInfo(),
                            fromLibrary: true));
                  });
                },
              );
            case LocalApiClientType.MANGA:
              final localMangaGalleryView =
                  item.localGalleryView as LocalMangaGalleryView;
              return LibraryCard(
                uid: localMangaGalleryView.uid,
                cover: localMangaGalleryView.cover,
                title: localMangaGalleryView.title,
                onLongPress: () {
                  showOkCancelAlertDialog(
                          context: context,
                          title: S.current
                              .gallery_view_manga_item_delete_from_library_confirmation_title(
                                  localMangaGalleryView.title),
                          okLabel: S.current
                              .gallery_view_manga_item_delete_from_library_confirmation_ok_label,
                          cancelLabel: S.current
                              .gallery_view_manga_item_delete_from_library_confirmation_cancel_label)
                      .then((value) {
                    if (value == OkCancelResult.ok) {
                      context.read<LibraryPageCubit>().delete(item, () {
                        showNotificationSnackBar(
                            context,
                            S.current
                                .gallery_view_manga_item_deleted_from_library_notification(
                                    localMangaGalleryView.title));
                      });
                    }
                  });
                },
                onTap: () {
                  // TODO
                  LocalApiSourcesService.instance
                      .get(item.localApiClientId)
                      .then((value) {
                    Navigator.of(context).pushNamed(Routes.mangaConcreteViewer,
                        arguments: MangaConcreteViewerData(
                            client: value.toApiClient(),
                            uid: localMangaGalleryView.uid,
                            galleryView: localMangaGalleryView.asGalleryView(),
                            configInfo: value.localConfigInfo.asConfigInfo(),
                            fromLibrary: true));
                  });
                },
              );
          }
        },
        itemCount: items.length,
      ),
    );
  }
}
