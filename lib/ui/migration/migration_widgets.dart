import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/services/migration/migration_models.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/images.dart';
import 'package:wakaranai/utils/text_styles.dart';

class MigrationCoverThumb extends StatelessWidget {
  const MigrationCoverThumb({
    super.key,
    required this.url,
    this.headers = const <String, String>{},
    this.width = 44,
    this.height = 64,
  });

  final String? url;
  final Map<String, String> headers;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: width,
        height: height,
        child: _buildImage(context),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    final String? source = url;
    if (source == null || source.isEmpty) {
      return _buildPlaceholder(context);
    }
    if (isLocalFilePath(source)) {
      return Image.file(
        File(source),
        fit: BoxFit.cover,
        errorBuilder: (BuildContext context, Object error, StackTrace? stack) =>
            _buildPlaceholder(context),
      );
    }
    return CachedNetworkImage(
      imageUrl: source,
      httpHeaders: headers,
      memCacheWidth: decodeWidthFor(context, width),
      fit: BoxFit.cover,
      placeholder: (BuildContext context, String _) =>
          _buildPlaceholder(context),
      errorWidget: (BuildContext context, String _, Object __) =>
          _buildPlaceholder(context),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return ColoredBox(
      color: AppColors.shimmerBase,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 18,
          color: AppColors.mainGrey,
        ),
      ),
    );
  }
}

class MigrationSubjectHeader extends StatelessWidget {
  const MigrationSubjectHeader({
    super.key,
    required this.subject,
    this.coverHeaders = const <String, String>{},
  });

  final MigrationSubject subject;
  final Map<String, String> coverHeaders;

  @override
  Widget build(BuildContext context) {
    final String? source = subject.sourceName;
    final String sourceLabel = source == null || source.isEmpty
        ? S.current.migration_search_unknown_source
        : source;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Row(
        children: <Widget>[
          MigrationCoverThumb(url: subject.cover, headers: coverHeaders),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  subject.title,
                  style: semibold(size: 16),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  S.current.migration_search_from(sourceLabel),
                  style: regular(size: 13, color: AppColors.mainGrey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MigrationCircleButton extends StatelessWidget {
  const MigrationCircleButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.overlay(0.06),
      shape: const CircleBorder(),
      child: IconButton(
        tooltip: tooltip,
        icon: Icon(icon, color: AppColors.mainWhite),
        onPressed: onPressed,
      ),
    );
  }
}

class MigrationPrimaryButton extends StatelessWidget {
  const MigrationPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.busy = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.mainBlack,
          disabledBackgroundColor: AppColors.overlay(0.06),
          disabledForegroundColor: AppColors.mainGrey,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: busy ? null : onPressed,
        child: _buildLabel(),
      ),
    );
  }

  Widget _buildLabel() {
    if (busy) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.4,
          color: AppColors.mainGrey,
        ),
      );
    }
    final IconData? leading = icon;
    final Widget text = Text(
      label,
      style: semibold(size: 15, color: AppColors.mainBlack),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
    if (leading == null) {
      return text;
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(leading, size: 20),
        const SizedBox(width: 8),
        Flexible(child: text),
      ],
    );
  }
}

class MigrationSwitchTile extends StatelessWidget {
  const MigrationSwitchTile({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final String? hint = subtitle;
    return InkWell(
      splashColor: AppColors.mediumLight.withValues(alpha: 0.2),
      onTap: onChanged == null ? null : () => onChanged!(!value),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
        child: Row(
          children: <Widget>[
            Icon(icon, size: 22, color: AppColors.mainGrey),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title, style: medium(size: 15)),
                  if (hint != null) ...<Widget>[
                    const SizedBox(height: 2),
                    Text(
                      hint,
                      style: regular(size: 12, color: AppColors.mainGrey),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Switch(
              value: value,
              activeThumbColor: AppColors.mainBlack,
              activeTrackColor: AppColors.primary,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class MigrationNoteRow extends StatelessWidget {
  const MigrationNoteRow({super.key, required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 20, color: AppColors.mainGrey),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: regular(size: 13, color: AppColors.mainGrey),
            ),
          ),
        ],
      ),
    );
  }
}

class MigrationSectionCard extends StatelessWidget {
  const MigrationSectionCard({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: AppColors.overlay(0.04),
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }
}

class MigrationSectionTitle extends StatelessWidget {
  const MigrationSectionTitle({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 10),
      child: Text(title, style: semibold(size: 18)),
    );
  }
}
