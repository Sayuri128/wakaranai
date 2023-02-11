import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/models/data/library_item.dart';
import 'package:wakaranai/models/data/local_gallery_view.dart';
import 'package:wakaranai/ui/anime_concrete_viewer/anime_concrete_viewer.dart';
import 'package:wakaranai/ui/home/library/cubit/library_page_cubit.dart';
import 'package:wakaranai/ui/home/library/library_card.dart';
import 'package:wakaranai/ui/manga_service_viewer/concrete_viewer/manga_concrete_viewer.dart';
import 'package:wakaranai/ui/routes.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakascript/api_clients/anime_api_client.dart';
import 'package:wakascript/api_clients/manga_api_client.dart';

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
              _buildPage(context, state.mangaItem, LibraryItemType.MANGA),
              _buildPage(context, state.animeItems, LibraryItemType.ANIME),
            ]);
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildPage(
      BuildContext context, List<LibraryItem> items, LibraryItemType type) {
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
            case LibraryItemType.ANIME:
              final localAnimeGalleryView =
                  item.localGalleryView as LocalAnimeGalleryView;
              return LibraryCard(
                uid: localAnimeGalleryView.uid,
                cover: localAnimeGalleryView.cover,
                title: localAnimeGalleryView.title,
                onTap: () {
                  Navigator.of(context).pushNamed(Routes.animeConcreteViewer,
                      arguments: AnimeConcreteViewerData(
                          client: item.localApiClient.toApiClient()
                              as AnimeApiClient,
                          uid: localAnimeGalleryView.uid,
                          galleryView: localAnimeGalleryView.asGalleryView(),
                          fromLibrary: true,
                          configInfo: item.localApiClient.localConfigInfo
                              .asConfigInfo()));
                },
              );
            case LibraryItemType.MANGA:
              final localMangaGalleryView =
                  item.localGalleryView as LocalMangaGalleryView;
              return LibraryCard(
                uid: localMangaGalleryView.uid,
                cover: localMangaGalleryView.cover,
                title: localMangaGalleryView.title,
                onTap: () {
                  final client =
                      item.localApiClient.toApiClient() as MangaApiClient;
                  Navigator.of(context).pushNamed(Routes.mangaConcreteViewer,
                      arguments: MangaConcreteViewerData(
                          client: client,
                          uid: localMangaGalleryView.uid,
                          galleryView: localMangaGalleryView.asGalleryView(),
                          configInfo: item.localApiClient.localConfigInfo
                              .asConfigInfo(),
                          fromLibrary: true));
                },
              );
          }
        },
        itemCount: items.length,
      ),
    );
  }
}
