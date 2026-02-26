import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:qr_scanner_generator/core/constants/app_constants.dart';
import 'package:qr_scanner_generator/core/services/app_preferences_repository.dart';

class HiveAppPreferencesRepository implements AppPreferencesRepository {
  HiveAppPreferencesRepository({
    Future<void> Function()? initializer,
    Future<Box<dynamic>> Function(String boxName)? boxOpener,
  }) : _initializer = initializer ?? Hive.initFlutter,
       _boxOpener = boxOpener ?? ((boxName) => Hive.openBox<dynamic>(boxName));

  final Future<void> Function() _initializer;
  final Future<Box<dynamic>> Function(String boxName) _boxOpener;
  Box<dynamic>? _box;

  static const String _themeModeKey = 'theme_mode';
  static const String _localeCodeKey = 'locale_code';

  @override
  Future<void> init() async {
    await _initializer();
    _box ??= await _boxOpener(AppConstants.appPreferencesBoxName);
  }

  Box<dynamic> get _prefsBox {
    final box = _box;
    if (box == null) {
      throw StateError('App preferences repository is not initialized.');
    }
    return box;
  }

  @override
  Future<Locale> readLocale() async {
    final code = _prefsBox.get(_localeCodeKey) as String?;
    switch (code) {
      case 'ru':
        return const Locale('ru');
      case 'tg':
        return const Locale('tg');
      case 'uz':
        return const Locale('uz');
      case 'en':
      default:
        return const Locale('en');
    }
  }

  @override
  Future<ThemeMode> readThemeMode() async {
    final stored = _prefsBox.get(_themeModeKey) as String?;
    switch (stored) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  @override
  Future<void> writeLocale(Locale locale) async {
    await _prefsBox.put(_localeCodeKey, locale.languageCode);
  }

  @override
  Future<void> writeThemeMode(ThemeMode mode) async {
    await _prefsBox.put(_themeModeKey, mode.name);
  }
}
