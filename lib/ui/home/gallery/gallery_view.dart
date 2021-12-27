import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:h_reader/blocs/nhentai/cache/doujinshi/doujinshi_cache_cubit.dart';
import 'package:h_reader/blocs/nhentai/galleries/nhentai_galleries_cubit.dart';
import 'package:h_reader/ui/widgets/skeleton_loaders.dart';
import 'package:provider/provider.dart';

import '../gallery_doujinshi_card.dart';

class GalleryView extends StatefulWidget {
  const GalleryView({Key? key}) : super(key: key);

  @override
  State<GalleryView> createState() => _GalleryViewState();
}

class _GalleryViewState extends State<GalleryView> {
  final GlobalKey _galleryPageKey = GlobalKey();
  final ScrollController _galleryScrollController = ScrollController();

  var _galleryPage = 1;

  @override
  void initState() {
    super.initState();

    _galleryScrollController.addListener(() {
      if (_galleryScrollController.position.atEdge &&
          _galleryScrollController.position.pixels != 0) {
        setState(() {
          _galleryPage++;
          _galleryPageKey.currentContext
              ?.read<NHentaiGalleriesCubit>()
              .requestGallery(_galleryPage);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<NHentaiGalleriesCubit>(
          create: (context) => NHentaiGalleriesCubit()..requestGallery(_galleryPage),
        ),
        BlocProvider<DoujinshiCacheCubit>(create: (context) => DoujinshiCacheCubit()..getAll())
      ],
      child: PageView(
        physics: const BouncingScrollPhysics(),
        children: [_buildGalleryListView(), _buildGalleryCachedListView()],
      ),
    );
  }

  BlocBuilder<DoujinshiCacheCubit, DoujinshiCacheState> _buildGalleryCachedListView() {
    return BlocBuilder<DoujinshiCacheCubit, DoujinshiCacheState>(builder: (context, state) {
      if (state is DoujinshiCacheReceived) {
        return ListView(
            children: state.doujinshi.map((e) => Text(e.doujinshi.title.pretty ?? '')).toList());
      } else {
        return const CircularProgressIndicator();
      }
    });
  }

  Widget _buildGalleryListView() {
    return ListView(
      controller: _galleryScrollController,
      physics: const BouncingScrollPhysics(),
      shrinkWrap: true,
      children: [
        BlocBuilder<NHentaiGalleriesCubit, NHentaiGalleriesState>(builder: (context, state) {
          if (state is NHentaiGalleriesReceived) {
            return Wrap(
              children: state.doujinshis.map((e) => GalleryDoujinshiCard(doujinshi: e)).toList(),
            );
          } else {
            return Wrap(
              children: List.generate(
                  16,
                  (index) => buildDoujinshiCardLoader(
                      width: MediaQuery.of(context).size.width * 0.5, height: 200)),
            );
          }
        })
      ],
    );
  }
}
