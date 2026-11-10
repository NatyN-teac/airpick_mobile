import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guzomy/l10n/app_localizations.dart';
import 'package:guzomy/src/features/countries/models/country.dart';
import 'package:guzomy/src/features/countries/widgets/country_picker_field.dart';

const _countries = [
  Country(id: '3', name: 'Kenya', countryCode: 'KE'),
  Country(id: '1', name: 'Ethiopia', countryCode: 'ET'),
  Country(id: '2', name: 'France', countryCode: 'FR'),
];

Widget _host(ValueChanged<Country> onSelected, {Country? selected}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: CountryPickerField(
          isDark: false,
          countries: _countries,
          selected: selected,
          hint: 'Select a country',
          onSelected: onSelected,
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('tapping the field opens a sorted list without a keyboard',
      (tester) async {
    Country? picked;
    await tester.pumpWidget(_host((c) => picked = c));

    // The field itself is not a text input.
    expect(find.byType(TextField), findsNothing);

    await tester.tap(find.text('Select a country'));
    await tester.pumpAndSettle();

    // All countries are listed, alphabetically, and nothing is focused.
    final names = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data)
        .where((d) => d == 'Ethiopia' || d == 'France' || d == 'Kenya')
        .toList();
    expect(names, ['Ethiopia', 'France', 'Kenya']);
    expect(
      tester.widget<EditableText>(find.byType(EditableText)).focusNode.hasFocus,
      isFalse,
    );

    await tester.tap(find.text('France'));
    await tester.pumpAndSettle();
    expect(picked?.countryCode, 'FR');
  });

  testWidgets('search narrows the list', (tester) async {
    await tester.pumpWidget(_host((_) {}));
    await tester.tap(find.text('Select a country'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'ken');
    await tester.pump();

    expect(find.text('Kenya'), findsOneWidget);
    expect(find.text('Ethiopia'), findsNothing);
    expect(find.text('France'), findsNothing);
  });
}
