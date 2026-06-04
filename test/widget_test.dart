import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:airpick/main.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    const secureStorage = FlutterSecureStorage();
    await tester.pumpWidget(
      AirpickApp(prefs: prefs, secureStorage: secureStorage),
    );
    // AppBloc starts in AppLoading while it checks shared_preferences
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
