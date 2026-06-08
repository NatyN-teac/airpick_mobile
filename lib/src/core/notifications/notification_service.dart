import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._();

  static final _plugin = FlutterLocalNotificationsPlugin();

  // Wired in main.dart to the chat deep-link handler. Receives the decoded
  // notification data (e.g. { refType: MATCH, refId: <matchId> }).
  static void Function(Map<String, dynamic> data)? onDeepLink;

  static const _channelId = 'airpick_main';
  static const _channelName = 'Airpick Notifications';
  static const _channelDesc = 'General Airpick notifications';

  static Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: _onTap,
    );
  }

  static Future<void> requestPermissions() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> show({
    int id = 0,
    required String title,
    required String body,
    String? payload,
  }) async {
    await _plugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload,
    );
  }

  static Future<void> cancel(int id) => _plugin.cancel(id);

  static Future<void> cancelAll() => _plugin.cancelAll();

  static void _onTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.isEmpty || onDeepLink == null) return;
    try {
      final data = jsonDecode(payload);
      if (data is Map<String, dynamic>) onDeepLink!(data);
    } catch (_) {/* non-JSON payload — ignore */}
  }

  // Called from the FCM message handler (foreground/opened-app) once
  // firebase_messaging is wired — routes { refType: MATCH, refId } deep links.
  static void handleData(Map<String, dynamic> data) => onDeepLink?.call(data);
}

// ── FCM integration guide ────────────────────────────────────────────────────
// When you're ready to add Firebase Cloud Messaging:
//
// 1. Add to pubspec.yaml:
//      firebase_core: ^3.x.x
//      firebase_messaging: ^15.x.x
//
// 2. Add google-services.json to android/app/
//    Add GoogleService-Info.plist to ios/Runner/
//
// 3. In main(), call Firebase.initializeApp() before NotificationService.initialize()
//
// 4. Add to this file:
//
//    static Future<void> initFcm() async {
//      final messaging = FirebaseMessaging.instance;
//      await messaging.requestPermission();
//      final token = await messaging.getToken();
//      // Send token to your backend
//
//      FirebaseMessaging.onMessage.listen((message) {
//        final notification = message.notification;
//        if (notification != null) {
//          show(title: notification.title ?? '', body: notification.body ?? '',
//               payload: message.data['route']);
//        }
//      });
//
//      FirebaseMessaging.onMessageOpenedApp.listen((message) {
//        _onTap(NotificationResponse(
//          notificationResponseType: NotificationResponseType.selectedNotification,
//          payload: message.data['route'],
//        ));
//      });
//    }
