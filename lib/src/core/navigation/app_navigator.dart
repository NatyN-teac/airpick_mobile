import 'package:flutter/widgets.dart';

// Global navigator key so non-widget code (notifications, deep links) can
// navigate. Wired into MaterialApp.navigatorKey in main.dart.
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();
