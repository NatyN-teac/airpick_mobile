import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  final SharedPreferences _prefs;

  static const _themeKey = 'settings_theme_mode';
  static const _localeKey = 'settings_locale';

  const SettingsRepository(this._prefs);

  // ── Theme ──────────────────────────────────────────────────────────────────

  ThemeMode getThemeMode() {
    return switch (_prefs.getString(_themeKey)) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> saveThemeMode(ThemeMode mode) async {
    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await _prefs.setString(_themeKey, value);
  }

  // ── Locale ─────────────────────────────────────────────────────────────────

  Locale getLocale() {
    final code = _prefs.getString(_localeKey);
    return Locale(code ?? 'en');
  }

  Future<void> saveLocale(Locale locale) async {
    await _prefs.setString(_localeKey, locale.languageCode);
  }
}
