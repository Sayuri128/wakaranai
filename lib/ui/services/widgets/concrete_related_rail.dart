import 'dart:async';

import 'package:capyscript/api_clients/api_client.dart';
import 'package:capyscript/modules/waka_models/models/common/gallery_view.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:flutter/material.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/ui/common/service_viewer/service_gallery_kind.dart';
import 'package:wakaranai/ui/gallery_view_card.dart';
import 'package:wakaranai/utils/serial_call_queue.dart';
import 'package:wakaranai/utils/text_styles.dart';

class ConcreteRelatedRail<T extends ApiClient, G extends GalleryView>
    extends StatefulWidget {
  const ConcreteRelatedRail({
    super.key,
    required this.client,
    required this.configInfo,
    required this.kind,
    required this.concreteUid,
    required this.galleryData,
    required this.coverHeaders,
  });

  static const double _cardWidth = 112;
  static const double _cardHeight = 168;

  final T client;
  final ConfigInfo configInfo;
  final ServiceGalleryKind<T, G> kind;
  final String concreteUid;
  final Map<String, dynamic> galleryData;
  final Map<String, String> coverHeaders;

  @override
  State<ConcreteRelatedRail<T, G>> createState() =>
      _ConcreteRelatedRailState<T, G>();
}

class _ConcreteRelatedRailState<T extends ApiClient, G extends GalleryView>
    extends State<ConcreteRelatedRail<T, G>> {
  late final Future<List<G>> _related = _load();

  Future<List<G>> _load() async {
    try {
      if (!await widget.client.supportsRelated()) {
        return <G>[];
      }
      final List<GalleryView> related = await runSerializedOn(
        widget.client,
        () => widget.client.getRelated(
          uid: widget.concreteUid,
          data: widget.galleryData,
        ),
      );
      return related
          .whereType<G>()
          .where((G item) => item.uid != widget.concreteUid)
          .toList(growable: false);
    } catch (error) {
      logger.w('getRelated failed for ${widget.concreteUid}: $error');
      return <G>[];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<G>>(
      future: _related,
      builder: (BuildContext context, AsyncSnapshot<List<G>> snapshot) {
        final List<G> related = snapshot.data ?? <G>[];
        if (related.isEmpty) {
          return const SizedBox.shrink();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                S.of(context).concrete_related_title,
                style: semibold(size: 18),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: ConcreteRelatedRail._cardHeight,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: related.length,
                separatorBuilder: (BuildContext context, int index) =>
                    const SizedBox(width: 10),
                itemBuilder: (BuildContext context, int index) =>
                    _buildCard(context, related[index]),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCard(BuildContext context, G item) {
    return SizedBox(
      width: ConcreteRelatedRail._cardWidth,
      child: GalleryViewCard(
        uid: 'related:${widget.concreteUid}:${item.uid}',
        headers: widget.coverHeaders,
        cover: widget.kind.coverOf(item),
        title: widget.kind.titleOf(item),
        compact: true,
        onTap: () => unawaited(Navigator.of(context).pushNamed(
          widget.kind.concreteRoute,
          arguments: widget.kind.concreteArguments(
            client: widget.client,
            configInfo: widget.configInfo,
            galleryView: item,
            coverHeaders: widget.coverHeaders,
          ),
        )),
      ),
    );
  }
}
