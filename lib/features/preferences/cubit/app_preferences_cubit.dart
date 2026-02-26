import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_scanner_generator/core/services/app_preferences_repository.dart';
import 'package:qr_scanner_generator/features/preferences/cubit/app_preferences_state.dart';

class AppPreferencesCubit extends Cubit<AppPreferencesState> {
  AppPreferencesCubit({required AppPreferencesRepository repository})
    : _repository = repository,
      super(const AppPreferencesState());

  final AppPreferencesRepository _repository;

  Future<void> load() async {
    await _repository.init();
    final themeMode = await _repository.readThemeMode();
    final locale = await _repository.readLocale();
    emit(state.copyWith(themeMode: themeMode, locale: locale, loaded: true));
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _repository.writeThemeMode(mode);
    emit(state.copyWith(themeMode: mode));
  }

  Future<void> setLocale(Locale locale) async {
    await _repository.writeLocale(locale);
    emit(state.copyWith(locale: locale));
  }
}
