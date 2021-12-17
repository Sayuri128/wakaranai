import 'package:h_reader/services/shared_preferences/shared_preferences_service.dart';

class SettingsRepository {
  static const String storeCachedImageDays = 'storeCachedImageDays';

  final SharedPreferencesService _service = SharedPreferencesService();

  Future<KeepCachedImageDay> getStoreCachedImageDays() async {
    final days = await _service.getOptions(storeCachedImageDays);
    if (days == 1) {
      return KeepCachedImageDay.ONE;
    } else if (days == 7) {
      return KeepCachedImageDay.WEEK;
    } else if (days == 30) {
      return KeepCachedImageDay.MONTH;
    } else {
      return KeepCachedImageDay.FOREVER;
    }
  }

  Future<void> changeStoreCachedImageDays(KeepCachedImageDay days) async {
    switch (days) {
      case KeepCachedImageDay.ONE:
        await _service.saveOption(storeCachedImageDays, 1);
        break;
      case KeepCachedImageDay.WEEK:
        await _service.saveOption(storeCachedImageDays, 7);
        break;
      case KeepCachedImageDay.MONTH:
        await _service.saveOption(storeCachedImageDays, 30);
        break;
      case KeepCachedImageDay.FOREVER:
        await _service.saveOption(storeCachedImageDays, -1);
        break;
    }
  }
}

enum KeepCachedImageDay { ONE, WEEK, MONTH, FOREVER }

extension KeepChachedImageDayExtension on KeepCachedImageDay {
  int getPeriod() {
    switch (this) {
      case KeepCachedImageDay.ONE:
        return 1;
      case KeepCachedImageDay.WEEK:
        return 7;
      case KeepCachedImageDay.MONTH:
        return 30;
      case KeepCachedImageDay.FOREVER:
        return 9999;
    }
  }
}
