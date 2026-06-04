import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/settings_repository.dart';

class LocaleCubit extends Cubit<Locale> {
  final SettingsRepository _repository;

  LocaleCubit(this._repository) : super(_repository.getLocale());

  static const supportedLocales = [
    Locale('en'), // English
    Locale('am'), // Amharic
    Locale('ar'), // Arabic
    Locale('fr'), // French
  ];

  void setLocale(Locale locale) {
    _repository.saveLocale(locale);
    emit(locale);
  }
}
