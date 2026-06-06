import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:airpick/l10n/app_localizations.dart';
import '../repository/settings_repository.dart';

class LocaleCubit extends Cubit<Locale> {
  final SettingsRepository _repository;

  LocaleCubit(this._repository) : super(_repository.getLocale());

  static List<Locale> get supportedLocales => AppLocalizations.supportedLocales;

  void setLocale(Locale locale) {
    _repository.saveLocale(locale);
    emit(locale);
  }
}
