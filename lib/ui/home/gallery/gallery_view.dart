import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:h_reader/blocs/nhentai/galleries/nhentai_galleries_cubit.dart';
import 'package:h_reader/models/nhentai/doujinshi/doujinshi.dart';
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
  final List<Doujinshi> _doujinshi = [];
  final List<Doujinshi> _doujinshiDisplay = [];

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
    return BlocProvider<NHentaiGalleriesCubit>(
      create: (context) => NHentaiGalleriesCubit()..requestGallery(_galleryPage),
      child: BlocListener<NHentaiGalleriesCubit, NHentaiGalleriesState>(
        listener: (context, state) {
          if (state is NHentaiGalleriesReceived) {
            _onDoujinshiReceived(state);
          }
        },
        child: Stack(
          children: [_buildGalleryListView(), _buildLoadingIndicator()],
        ),
      ),
    );
  }

  void _onDoujinshiReceived(NHentaiGalleriesReceived state) {
    setState(() {
      _doujinshi.addAll(state.doujinshis);
      _filterDoujinshis();
    });
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

  Builder _buildGalleryListView() {
    return Builder(
        key: _galleryPageKey,
        builder: (context) => Center(
              child: ListView(
                controller: _galleryScrollController,
                physics: const BouncingScrollPhysics(),
                shrinkWrap: true,
                children: [
                  Wrap(
                    children: _doujinshi.map((e) => GalleryDoujinshiCard(doujinshi: e)).toList(),
                  ),
                ],
              ),
            ));
  }

  void _filterDoujinshis() {
    setState(() {
      _doujinshiDisplay.clear();
      _doujinshiDisplay.addAll(_doujinshi);
    });
  }
}
