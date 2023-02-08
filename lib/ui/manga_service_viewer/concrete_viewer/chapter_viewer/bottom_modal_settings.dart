import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/chapter_view/chapter_view_cubit.dart';
import 'package:wakaranai/blocs/chapter_view/chapter_view_state.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/manga_service_viewer/concrete_viewer/chapter_viewer/chapter_view_mode.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class BottomModalSettings extends StatefulWidget {
  const BottomModalSettings(
      {Key? key, required this.scaffoldKey, required this.state})
      : super(key: key);

  final GlobalKey scaffoldKey;
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
      children: [
        const SizedBox(
          height: 32,
        ),
        Flexible(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                          .map((e) => DropdownMenuItem(
                                value: e,
                                alignment: Alignment.center,
                                child: Text(chapterViewModelToString(e),
                                    textAlign: TextAlign.center),
                              ))
                          .toList(),
                      onChanged: (mode) {
                        if (mode != null) {
                          widget.scaffoldKey.currentContext
                              ?.read<ChapterViewCubit>()
                              .onModeChanged(mode);
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
          title:
              Text(S.current.chapter_viewer_bottom_modal_settings_tap_controls),
          value: _enableTapControlsState,
          onChanged: (newValue) {
            if (newValue == null) {
              return;
            }

            widget.scaffoldKey.currentContext
                ?.read<ChapterViewCubit>()
                .onSetControls(newValue);
            _enableTapControlsState = newValue;
            if (mounted) {
              setState(() {});
            }
          },
          contentPadding: EdgeInsets.symmetric(horizontal: 24.0),
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
