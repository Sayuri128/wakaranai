import 'package:flutter/material.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

/// A centered empty/error state: an icon, a title, an optional message and an
/// optional row of action buttons. Used for the service viewer's empty and
/// error screens.
class ServiceViewerMessage extends StatelessWidget {
  const ServiceViewerMessage({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actions = const <Widget>[],
  });

  final IconData icon;
  final String title;
  final String? message;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 64, color: AppColors.mainGrey),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: semibold(size: 18),
            ),
            if (message != null) ...<Widget>[
              const SizedBox(height: 8),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: regular(size: 14, color: AppColors.mainGrey),
              ),
            ],
            if (actions.isNotEmpty) ...<Widget>[
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: actions,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
