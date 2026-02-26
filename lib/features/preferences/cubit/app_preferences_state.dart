import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class AppPreferencesState extends Equatable {
  const AppPreferencesState({
    this.themeMode = ThemeMode.system,
    this.locale = const Locale('en'),
    this.loaded = false,
  });

  final ThemeMode themeMode;
  final Locale locale;
  final bool loaded;

  AppPreferencesState copyWith({
    ThemeMode? themeMode,
    Locale? locale,
    bool? loaded,
  }) {
    return AppPreferencesState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      loaded: loaded ?? this.loaded,
    );
  }

  @override
  List<Object?> get props => <Object?>[themeMode, locale, loaded];
}
