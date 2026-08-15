import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  final bool pushNotifications;
  final bool alertSounds;
  final bool darkMode;
  final String language;
  final String units;

  const AppSettings({
    required this.pushNotifications,
    required this.alertSounds,
    required this.darkMode,
    required this.language,
    required this.units,
  });

  AppSettings copyWith({
    bool? pushNotifications,
    bool? alertSounds,
    bool? darkMode,
    String? language,
    String? units,
  }) {
    return AppSettings(
      pushNotifications: pushNotifications ?? this.pushNotifications,
      alertSounds: alertSounds ?? this.alertSounds,
      darkMode: darkMode ?? this.darkMode,
      language: language ?? this.language,
      units: units ?? this.units,
    );
  }

  static const AppSettings defaults = AppSettings(
    pushNotifications: true,
    alertSounds: true,
    darkMode: false,
    language: 'English',
    units: '°C, km/h',
  );
}

class SettingsService {
  static const _kPush = 'settings_push_notifications';
  static const _kSounds = 'settings_alert_sounds';
  static const _kDark = 'settings_dark_mode';
  static const _kLang = 'settings_language';
  static const _kUnits = 'settings_units';

  static Future<AppSettings> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return AppSettings(
        pushNotifications: prefs.getBool(_kPush) ?? true,
        alertSounds: prefs.getBool(_kSounds) ?? true,
        darkMode: prefs.getBool(_kDark) ?? false,
        language: prefs.getString(_kLang) ?? 'English',
        units: prefs.getString(_kUnits) ?? '°C, km/h',
      );
    } catch (e) {
      debugPrint("Settings load failed, using defaults: $e");
      return AppSettings.defaults;
    }
  }

  static Future<void> _saveField(
      String key, dynamic value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (value is bool) {
        await prefs.setBool(key, value);
      } else if (value is String) {
        await prefs.setString(key, value);
      }
    } catch (e) {
      debugPrint("Settings save failed for $key: $e");
    }
  }

  static Future<void> saveAll(AppSettings s) async {
    await _saveField(_kPush, s.pushNotifications);
    await _saveField(_kSounds, s.alertSounds);
    await _saveField(_kDark, s.darkMode);
    await _saveField(_kLang, s.language);
    await _saveField(_kUnits, s.units);
  }

  static Future<void> setPush(bool v) => _saveField(_kPush, v);
  static Future<void> setSounds(bool v) => _saveField(_kSounds, v);
  static Future<void> setDarkMode(bool v) => _saveField(_kDark, v);
  static Future<void> setLanguage(String v) => _saveField(_kLang, v);
  static Future<void> setUnits(String v) => _saveField(_kUnits, v);

  static const List<String> languages = [
    'English',
    'Urdu',
    'Arabic',
    'Hindi',
    'Turkish',
  ];

  static const List<String> unitsOptions = [
    '°C, km/h',
    '°F, mph',
    '°C, m/s',
    'K, knots',
  ];
}
