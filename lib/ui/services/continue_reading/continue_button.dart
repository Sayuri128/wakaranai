import 'package:flutter/material.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/services/continue_reading/continue_target.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class ConcreteContinueAction {
  const ConcreteContinueAction({
    required this.kind,
    required this.title,
    required this.onTap,
  });

  final ContinueKind kind;
  final String title;
  final VoidCallback onTap;
}

class AutoContinueRequest {
  bool _pending = true;

  bool consume() {
    final bool pending = _pending;
    _pending = false;
    return pending;
  }
}

class ConcreteContinueButton extends StatelessWidget {
  const ConcreteContinueButton({super.key, required this.action});

  final ConcreteContinueAction action;

  @override
  Widget build(BuildContext context) {
    final String label = action.kind == ContinueKind.start
        ? S.of(context).concrete_continue_start
        : S.of(context).concrete_continue_resume;
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: action.onTap,
        child: SizedBox(
          height: 48,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: <Widget>[
                Icon(Icons.play_arrow_rounded, color: AppColors.mainBlack),
                const SizedBox(width: 8),
                Text(label, style: semibold(size: 15, color: AppColors.mainBlack)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    action.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: regular(size: 14, color: AppColors.mainBlack),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
