import 'package:airpick/l10n/app_localizations.dart';
import 'package:airpick/src/core/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

/// Verifies the app actually swaps localized strings when the MaterialApp
/// locale changes — i.e. the language-switch mechanism itself works.
void main() {
  Widget appAt(Locale locale) => MaterialApp(
        locale: resolveAppLocale(locale),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Builder(builder: (context) => Text(l10n(context).skip)),
      );

  testWidgets('English locale renders English string', (tester) async {
    await tester.pumpWidget(appAt(const Locale('en')));
    await tester.pumpAndSettle();
    expect(find.text('Skip'), findsOneWidget);
  });

  testWidgets('Amharic locale renders Amharic string', (tester) async {
    await tester.pumpWidget(appAt(const Locale('am')));
    await tester.pumpAndSettle();
    expect(find.text('ዝለል'), findsOneWidget);
  });
}
