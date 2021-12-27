import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:h_reader/blocs/nhentai/cache/doujinshi/doujinshi_cache_cubit.dart';
import 'package:h_reader/blocs/nhentai/galleries/nhentai_galleries_cubit.dart';
import 'package:h_reader/generated/l10n.dart';
import 'package:h_reader/models/nhentai/doujinshi/doujinshi.dart';
import 'package:h_reader/ui/widgets/skeleton_loaders.dart';
import 'package:provider/provider.dart';

import 'gallery_cached_doujinshi_card.dart';
import 'gallery_doujinshi_card.dart';

class GalleryView extends StatefulWidget {
  const GalleryView({Key? key}) : super(key: key);

  @override
  State<GalleryView> createState() => _GalleryViewState();
}

class _GalleryViewState extends State<GalleryView> {
  final GlobalKey _galleryPageKey = GlobalKey();
  final ScrollController _galleryScrollController = ScrollController();

  var _galleryPage = 1;

  final List<Doujinshi> _doujinshi = [];
  final List<Doujinshi> _doujinshiDisplay = [];

  @override
  void initState() {
    super.initState();

    _galleryScrollController.addListener(() {
      if (_galleryScrollController.position.atEdge &&
          _galleryScrollController.position.pixels != 0) {
        _galleryPage++;
        _galleryPageKey.currentContext?.read<NHentaiGalleriesCubit>().requestGallery(_galleryPage);
      }
    });
  }

  void _onDoujinshiReceived(NHentaiGalleriesReceived state) {
    _doujinshi.addAll(state.doujinshis);
    _filterDoujinshis();
  }

  void _filterDoujinshis() {
    setState(() {
      _doujinshiDisplay.clear();
      _doujinshiDisplay.addAll(_doujinshi);
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
      child: MultiBlocListener(
        listeners: [
          BlocListener<NHentaiGalleriesCubit, NHentaiGalleriesState>(listener: (context, state) {
            if (state is NHentaiGalleriesReceived) {
              _onDoujinshiReceived(state);
            }
          })
        ],
        child: Builder(builder: (context) {
          return _buildPage(context);
        }),
      ),
    );
  }

  Widget _buildPage(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TabBar(tabs: [
              Tab(text: S.current.gallery_view_menu_nhentai_title),
              Tab(text: S.current.gallery_view_menu_cached_title)
            ]),
            Expanded(
              child: TabBarView(physics: const BouncingScrollPhysics(), children: [
                Stack(children: [_buildGalleryListView(), _buildLoadingIndicator()]),
                _buildGalleryCachedListView()
              ]),
            )
          ],
        ));
  }

  BlocBuilder<NHentaiGalleriesCubit, NHentaiGalleriesState> _buildLoadingIndicator() {
    return BlocBuilder<NHentaiGalleriesCubit, NHentaiGalleriesState>(builder: (_, state) {
      if (state is NHentaiGalleriesLoading) {
        return const Center(child: CircularProgressIndicator());
      } else {
        return const SizedBox();
      }
    });
  }

  BlocBuilder<DoujinshiCacheCubit, DoujinshiCacheState> _buildGalleryCachedListView() {
    return BlocBuilder<DoujinshiCacheCubit, DoujinshiCacheState>(builder: (context, state) {
      return ListView(physics: const BouncingScrollPhysics(), shrinkWrap: true, children: [
        state is DoujinshiCacheReceived
            ? Wrap(
                children: state.doujinshi
                    .map((e) => GalleryCachedDoujinshiCard(
                          data: e,
                        ))
                    .toList())
            : Wrap(
                children: List.generate(
                    16,
                    (index) => buildDoujinshiCardLoader(
                        width: MediaQuery.of(context).size.width * 0.5, height: 200)))
      ]);
    });
  }

  Widget _buildGalleryListView() {
    return ListView(
      controller: _galleryScrollController,
      physics: const BouncingScrollPhysics(),
      shrinkWrap: true,
      children: [
        Wrap(
          children: _doujinshi.map((e) => GalleryDoujinshiCard(doujinshi: e)).toList(),
        ),
      ],
    );
  }
}
