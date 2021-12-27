import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:h_reader/blocs/nhentai/cache/doujinshi/doujinshi_cache_cubit.dart';
import 'package:h_reader/generated/l10n.dart';
import 'package:h_reader/models/sqlite/cache/cached_doujinshi/cached_doujinshi.dart';
import 'package:h_reader/ui/widgets/cached_image.dart';
import 'package:h_reader/ui/widgets/skeleton_loaders.dart';
import 'package:h_reader/utils/app_colors.dart';
import 'package:h_reader/utils/nhentai_urls.dart';
import 'package:h_reader/utils/text_styles.dart';

import '../../../main.dart';
import '../../routes.dart';

class GalleryCachedDoujinshiCard extends StatelessWidget {
  const GalleryCachedDoujinshiCard({Key? key, required this.data}) : super(key: key);

  final CachedDoujinshi data;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DoujinshiCacheCubit>(
      create: (context) => DoujinshiCacheCubit()..verifyCache(data),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.5,
        child: Card(
          shadowColor: AppColors.mainGrey,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          child: BlocBuilder<DoujinshiCacheCubit, DoujinshiCacheState>(
            builder: (context, state) {
              if (state is DoujinshiCacheVerifiedResult) {
                if (state.result) {
                  return _buildVerified(context);
                } else {
                  return _buildDataDoesNotExist(context);
                }
              } else {
                return buildDoujinshiCardLoader(
                    width: MediaQuery.of(context).size.width, height: 200);
              }
            },
          ),
        ),
      ),
    );
  }

  Container _buildDataDoesNotExist(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 200,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.0)),
      child: Center(
          child: Text(
              S.current.doujinshi_view_cached_data_does_not_exit_error_message(
                  data.doujinshi.title.pretty ?? ''),
              textAlign: TextAlign.center)),
    );
  }

  InkWell _buildVerified(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8.0),
      onTap: () {
        MyApp.navigator?.pushNamed(Routes.doujinshiView, arguments: data.doujinshi).then((value) {
          context.read<DoujinshiCacheCubit>().verifyCache(data);
        });
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            CachedImage(
                url: NHentaiUrls.thumbnailUrl(data.mediaId, data.doujinshi.images.thumbnail.t),
                width: 200,
                height: 180),
            const SizedBox(height: 8),
            Center(
              child:
                  Text(data.doujinshi.title.pretty?.overflow ?? '', maxLines: 1, style: medium()),
            )
          ],
        ),
      ),
    );
  }
}
