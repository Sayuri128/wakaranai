import 'package:wakaranai/generated/l10n.dart';

String? titleStatusLabel(String? status) {
  switch (status) {
    case 'RELEASED':
      return S.current.title_status_released;
    case 'ONGOING':
      return S.current.title_status_ongoing;
    case 'PAUSED':
      return S.current.title_status_paused;
    case 'ANNOUNCE':
      return S.current.title_status_announce;
    case 'CANCELED':
      return S.current.title_status_canceled;
    default:
      return null;
  }
}
