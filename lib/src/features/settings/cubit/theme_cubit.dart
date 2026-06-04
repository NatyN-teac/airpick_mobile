import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/settings_repository.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final SettingsRepository _repository;

  ThemeCubit(this._repository) : super(_repository.getThemeMode());

  void setLight() => _update(ThemeMode.light);
  void setDark() => _update(ThemeMode.dark);
  void setSystem() => _update(ThemeMode.system);

  void toggle() =>
      state == ThemeMode.dark ? setLight() : setDark();

  void _update(ThemeMode mode) {
    _repository.saveThemeMode(mode);
    emit(mode);
  }
}
