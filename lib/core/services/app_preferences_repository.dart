import 'package:flutter/material.dart';

abstract class AppPreferencesRepository {
  Future<void> init();

  Future<ThemeMode> readThemeMode();

  Future<void> writeThemeMode(ThemeMode mode);

  Future<Locale> readLocale();

  Future<void> writeLocale(Locale locale);
}
