import 'package:flutter/material.dart';
import 'package:airpick/l10n/app_localizations.dart';

/// Returns a locale that [AppLocalizations] can load, falling back to English.
Locale resolveAppLocale(Locale locale) {
  for (final supported in AppLocalizations.supportedLocales) {
    if (supported.languageCode == locale.languageCode) return locale;
  }
  return const Locale('en');
}

/// Never null — falls back to English if delegates are missing (e.g. dialog overlay).
AppLocalizations l10n(BuildContext context) {
  return AppLocalizations.of(context) ??
      lookupAppLocalizations(resolveAppLocale(Localizations.localeOf(context)));
}
