import 'package:flutter/foundation.dart';

import 'settings_service.dart';

class SettingsNotifier extends ChangeNotifier {
  AppSettings _settings = AppSettings.defaults;
  bool _loaded = false;

  AppSettings get settings => _settings;
  bool get loaded => _loaded;

  bool get darkMode => _settings.darkMode;
  bool get pushNotifications => _settings.pushNotifications;
  bool get alertSounds => _settings.alertSounds;
  String get language => _settings.language;
  String get units => _settings.units;

  static final SettingsNotifier instance = SettingsNotifier._();
  SettingsNotifier._();

  Future<void> load() async {
    _settings = await SettingsService.load();
    _loaded = true;
    notifyListeners();
  }

  Future<void> setPushNotifications(bool v) async {
    _settings = _settings.copyWith(pushNotifications: v);
    notifyListeners();
    await SettingsService.setPush(v);
  }

  Future<void> setAlertSounds(bool v) async {
    _settings = _settings.copyWith(alertSounds: v);
    notifyListeners();
    await SettingsService.setSounds(v);
  }

  Future<void> setDarkMode(bool v) async {
    _settings = _settings.copyWith(darkMode: v);
    notifyListeners();
    await SettingsService.setDarkMode(v);
  }

  Future<void> setLanguage(String v) async {
    if (v == _settings.language) return;
    _settings = _settings.copyWith(language: v);
    notifyListeners();
    await SettingsService.setLanguage(v);
  }

  Future<void> setUnits(String v) async {
    if (v == _settings.units) return;
    _settings = _settings.copyWith(units: v);
    notifyListeners();
    await SettingsService.setUnits(v);
  }
}
