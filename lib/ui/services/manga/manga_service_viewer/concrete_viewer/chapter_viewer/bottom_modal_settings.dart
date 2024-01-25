import 'package:flutter/material.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/services/cubits/chapter_view/chapter_view_cubit.dart';
import 'package:wakaranai/ui/services/cubits/chapter_view/chapter_view_state.dart';
import 'package:wakaranai/ui/services/manga/manga_service_viewer/concrete_viewer/chapter_viewer/chapter_view_mode.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class BottomModalSettings extends StatefulWidget {
  const BottomModalSettings({
    super.key,
    required this.chapterViewCubit,
    required this.state,
  });

  final ChapterViewCubit chapterViewCubit;
  final ChapterViewInitialized state;

  @override
  State<BottomModalSettings> createState() => _BottomModalSettingsState();
}

class _BottomModalSettingsState extends State<BottomModalSettings> {
  bool _enableTapControlsState = false;

  @override
  void initState() {
    super.initState();
    _enableTapControlsState = widget.state.controlsEnabled;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        const SizedBox(
          height: 32,
        ),
        Flexible(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                    width: 128,
                    child: Text(
                      S.current
                          .chapter_viewer_bottom_modal_settings_reading_mode_title,
                      style: semibold(size: 18),
                    )),
                Flexible(
                  child: DropdownButtonFormField<ChapterViewMode>(
                      value: widget.state.mode,
                      borderRadius: BorderRadius.circular(16.0),
                      style: medium(size: 18),
                      icon: const Icon(Icons.arrow_drop_down_rounded),
                      decoration: InputDecoration(
                          labelStyle: medium(size: 18),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16.0),
                              borderSide:
                                  const BorderSide(color: Colors.transparent)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16.0),
                              borderSide:
                                  const BorderSide(color: Colors.transparent)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16.0),
                              borderSide:
                                  const BorderSide(color: Colors.transparent))),
                      items: ChapterViewMode.values
                          .map((ChapterViewMode e) => DropdownMenuItem(
                                value: e,
                                alignment: Alignment.center,
                                child: Text(chapterViewModelToString(e),
                                    textAlign: TextAlign.center),
                              ))
                          .toList(),
                      onChanged: (ChapterViewMode? mode) {
                        if (mode != null) {
                          widget.chapterViewCubit.onModeChanged(mode);
                        }
                      }),
                )
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 2,
        ),
        CheckboxListTile(
          title: Text(
            S.current.chapter_viewer_bottom_modal_settings_tap_controls,
            style: medium(),
          ),
          value: _enableTapControlsState,
          onChanged: (bool? newValue) {
            if (newValue == null) {
              return;
            }

            widget.chapterViewCubit.onSetControls(newValue);
            _enableTapControlsState = newValue;
            if (mounted) {
              setState(() {});
            }
          },
          contentPadding: const EdgeInsets.symmetric(horizontal: 24.0),
          activeColor: AppColors.primary,
          controlAffinity:
              ListTileControlAffinity.leading, //  <-- leading Checkbox
        ),
        const SizedBox(
          height: 16,
        )
      ],
    );
  }
}
