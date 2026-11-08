import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/trackers/trackers_cubit.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/services/trackers/tracker_models.dart';
import 'package:wakaranai/services/trackers/tracker_sync_service.dart';
import 'package:wakaranai/ui/widgets/cover_image.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class TrackerLinkRequest {
  const TrackerLinkRequest({
    required this.concreteUid,
    required this.extensionUid,
    required this.title,
    required this.type,
    this.localProgress,
  });

  final String concreteUid;
  final String extensionUid;
  final String title;
  final TrackerMediaType type;
  final int? localProgress;
}

Future<bool?> showTrackerSearchSheet(
  BuildContext context, {
  required TrackerId trackerId,
  required TrackerLinkRequest request,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.backgroundColor,
    constraints: BoxConstraints(
      maxHeight: MediaQuery.sizeOf(context).height * 0.9,
    ),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext sheetContext) => _TrackerSearchSheet(
      trackerId: trackerId,
      request: request,
      sync: context.read<TrackerSyncService>(),
      trackerName: context.read<TrackersCubit>().nameOf(trackerId),
    ),
  );
}

class _TrackerSearchSheet extends StatefulWidget {
  const _TrackerSearchSheet({
    required this.trackerId,
    required this.request,
    required this.sync,
    required this.trackerName,
  });

  final TrackerId trackerId;
  final TrackerLinkRequest request;
  final TrackerSyncService sync;
  final String trackerName;

  @override
  State<_TrackerSearchSheet> createState() => _TrackerSearchSheetState();
}

class _TrackerSearchSheetState extends State<_TrackerSearchSheet> {
  late final TextEditingController _query =
      TextEditingController(text: widget.request.title);
  List<TrackerSearchResult>? _results;
  bool _searching = false;
  bool _linking = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    unawaited(_search());
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final String query = _query.text.trim();
    if (query.isEmpty) {
      return;
    }
    setState(() {
      _searching = true;
      _error = null;
    });
    try {
      final List<TrackerSearchResult> results = await widget.sync.search(
        widget.trackerId,
        query,
        widget.request.type,
      );
      if (mounted) {
        setState(() => _results = results);
      }
    } catch (error) {
      logger.w('Tracker search failed: $error');
      if (mounted) {
        setState(() => _error = S.current.tracker_search_failed);
      }
    } finally {
      if (mounted) {
        setState(() => _searching = false);
      }
    }
  }

  Future<void> _link(TrackerSearchResult result) async {
    setState(() => _linking = true);
    try {
      await widget.sync.link(
        trackerId: widget.trackerId,
        concreteUid: widget.request.concreteUid,
        extensionUid: widget.request.extensionUid,
        type: widget.request.type,
        result: result,
        localProgress: widget.request.localProgress,
      );
      final int? malId = result.malId;
      if (malId != null) {
        await widget.sync.linkOthersByMalId(
          origin: widget.trackerId,
          concreteUid: widget.request.concreteUid,
          extensionUid: widget.request.extensionUid,
          type: widget.request.type,
          malId: malId,
          localProgress: widget.request.localProgress,
        );
      }
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (error) {
      logger.w('Tracker link failed: $error');
      if (mounted) {
        setState(() {
          _linking = false;
          _error = S.current.tracker_link_failed;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                decoration: BoxDecoration(
                  color: AppColors.overlay(0.18),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Text(
                S.of(context).tracker_search_title(widget.trackerName),
                style: semibold(size: 18),
              ),
            ),
            Flexible(child: _buildResults(context)),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Text(
                  _error!,
                  style: regular(size: 13, color: AppColors.red),
                ),
              ),
            _buildSearchField(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: TextField(
        controller: _query,
        textInputAction: TextInputAction.search,
        onSubmitted: (_) => unawaited(_search()),
        style: regular(size: 15),
        cursorColor: AppColors.primary,
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.overlay(0.06),
          hintText: S.of(context).tracker_search_hint,
          hintStyle: regular(size: 15, color: AppColors.mainGrey),
          prefixIcon: Icon(Icons.search_rounded, color: AppColors.mainGrey),
          suffixIcon: IconButton(
            icon: Icon(Icons.arrow_forward_rounded, color: AppColors.primary),
            onPressed: () => unawaited(_search()),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildResults(BuildContext context) {
    final List<TrackerSearchResult>? results = _results;
    if (_searching || _linking || results == null) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }
    if (results.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          S.of(context).tracker_search_empty,
          textAlign: TextAlign.center,
          style: regular(size: 14, color: AppColors.mainGrey),
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      reverse: true,
      itemCount: results.length,
      itemBuilder: (BuildContext context, int index) =>
          _buildResult(context, results[index]),
    );
  }

  Widget _buildResult(BuildContext context, TrackerSearchResult result) {
    final List<String> meta = <String>[
      if (result.format != null) result.format!,
      if (result.year != null) '${result.year}',
      if (result.totalCount != null) '${result.totalCount}',
    ];
    return InkWell(
      onTap: () => unawaited(_link(result)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 44,
                height: 62,
                child: result.cover == null
                    ? ColoredBox(color: AppColors.overlay(0.08))
                    : CoverImage(
                        url: result.cover!,
                        logicalWidth: 44,
                        placeholder: (BuildContext context) =>
                            ColoredBox(color: AppColors.overlay(0.08)),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    result.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: medium(size: 15),
                  ),
                  if (meta.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 2),
                    Text(
                      meta.join(' · '),
                      style: regular(size: 12, color: AppColors.mainGrey),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
