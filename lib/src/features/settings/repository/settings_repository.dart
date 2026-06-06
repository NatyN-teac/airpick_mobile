import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../home/cubit/user_mode_cubit.dart';
import '../../profile/models/profile_snapshot.dart';

class SettingsRepository {
  final SharedPreferences _prefs;

  static const _themeKey = 'settings_theme_mode';
  static const _localeKey = 'settings_locale';
  static const _modeKey = 'settings_user_mode';
  static const _profileKey = 'settings_profile_snapshot';

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

  // ── User mode ──────────────────────────────────────────────────────────────

  UserMode getMode() =>
      UserModeX.fromApi(_prefs.getString(_modeKey) ?? 'SHIPPER');

  Future<void> saveMode(UserMode mode) async {
    await _prefs.setString(_modeKey, mode.apiValue);
  }

  // ── Profile snapshot ───────────────────────────────────────────────────────

  ProfileSnapshot? getProfile() {
    final raw = _prefs.getString(_profileKey);
    if (raw == null) return null;
    try {
      return ProfileSnapshot.decode(raw);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveProfile(ProfileSnapshot p) async {
    await _prefs.setString(_profileKey, p.encode());
  }

  Future<void> clearProfile() async {
    await _prefs.remove(_profileKey);
  }
}
