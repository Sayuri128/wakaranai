import 'package:flutter/material.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/repositories/shared_pref/player_preferences.dart';

IconData fitModeIcon(PlayerFitMode mode) {
  switch (mode) {
    case PlayerFitMode.fit:
      return Icons.fit_screen_rounded;
    case PlayerFitMode.fill:
      return Icons.crop_free_rounded;
    case PlayerFitMode.stretch:
      return Icons.open_in_full_rounded;
  }
}

String fitModeLabel(PlayerFitMode mode) {
  switch (mode) {
    case PlayerFitMode.fit:
      return S.current.native_player_fit_mode_fit;
    case PlayerFitMode.fill:
      return S.current.native_player_fit_mode_fill;
    case PlayerFitMode.stretch:
      return S.current.native_player_fit_mode_stretch;
  }
}
