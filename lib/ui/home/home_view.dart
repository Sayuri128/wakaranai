import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:h_reader/blocs/nhentai/galleries/nhentai_galleries_cubit.dart';
import 'package:h_reader/generated/l10n.dart';
import 'package:h_reader/ui/widgets/bottom_navigation.dart';
import 'package:h_reader/utils/app_colors.dart';
import 'package:h_reader/utils/nhentai_urls.dart';
import 'package:provider/src/provider.dart';

class HomeView extends StatefulWidget {
  HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  var _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [
      Builder(builder: (context) {
        return Center(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            shrinkWrap: true,
            children: [
              ElevatedButton(
                onPressed: () {
                  context.read<NHentaiGalleriesCubit>().requestGallery(1);
                },
                child: Text('Load doujinshi'),
              ),
              BlocBuilder<NHentaiGalleriesCubit, NHentaiGalleriesState>(builder: (context, state) {
                if (state is NHentaiGalleriesReceived) {
                  return Column(
                    children: state.doujishis.map((e) {
                      return Column(
                        children: [
                          Text(e.title.pretty ?? ''),
                          Image.network(
                            NHentaiUrls.thumbnailUrl(e.mediaId, e.images.thumbnail.t),
                            fit: BoxFit.fitHeight,
                            height: 200,
                            width: 120,
                          )
                        ],
                      );
                    }).toList(),
                  );
                } else {
                  return const SizedBox();
                }
              })
            ],
          ),
        );
      }),
      Center(
        child: Text('settings'),
      )
    ];

    return MultiBlocProvider(
      providers: [BlocProvider<NHentaiGalleriesCubit>(create: (_) => NHentaiGalleriesCubit())],
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 50,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(8.0), bottomRight: Radius.circular(8.0))),
          backgroundColor: AppColors.accentGreen,
          centerTitle: true,
          title: Text(S.current.app_name),
        ),
        body: widgets.elementAt(_currentPage),
        bottomNavigationBar: BottomNavigation(onTap: (index) {
          setState(() {
            _currentPage = index;
          });
        }),
      ),
    );
  }
}
