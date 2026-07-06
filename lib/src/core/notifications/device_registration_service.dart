import 'dart:async';
import 'dart:io' show Platform;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../network/api_client.dart';
import '../storage/token_storage.dart';

/// Registers/unregisters this device's FCM token with the backend so the
/// server can deliver push notifications.
///
/// - Call [registerAfterLogin] after every successful sign-in (the JWT must
///   already be stored so the request is authenticated).
/// - Call [unregisterBeforeLogout] before clearing the JWT on logout, because
///   the DELETE request needs the Authorization header.
/// - Call [start] once at app launch to (re)register when a session already
///   exists and to keep the backend in sync when FCM rotates the token.
class DeviceRegistrationService {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  DeviceRegistrationService(this._apiClient, this._tokenStorage);

  static const _devicesPath = '/users/devices';

  StreamSubscription<String>? _tokenRefreshSub;

  FirebaseMessaging get _messaging => FirebaseMessaging.instance;

  /// Wires up token-refresh handling and registers the current token if the
  /// user is already signed in (e.g. an app relaunch). Safe to call once.
  Future<void> start() async {
    if (!_isSupportedPlatform) return;
    // FCM can rotate the token at any time; keep the backend in sync, but only
    // while there's an active session to authenticate the request.
    _tokenRefreshSub ??= _messaging.onTokenRefresh.listen((token) async {
      if (await _hasSession()) {
        await _sendRegistration(token);
      }
    });
    if (await _hasSession()) {
      await registerAfterLogin();
    }
  }

  /// Obtains the FCM token and registers it with the backend. Best-effort:
  /// failures are logged but never surfaced, so a registration hiccup can't
  /// block the user from entering the app.
  Future<void> registerAfterLogin() async {
    if (!_isSupportedPlatform) return;
    try {
      // Requesting permission is required for iOS to mint an APNs token (and
      // therefore an FCM token). It's a no-op if already granted.
      await _messaging.requestPermission();

      final token = await _resolveFcmToken();
      if (token == null || token.isEmpty) {
        debugPrint('[DeviceRegistration] No FCM token available; skipping.');
        return;
      }
      await _sendRegistration(token);
    } catch (e, st) {
      debugPrint('[DeviceRegistration] register failed: $e\n$st');
    }
  }

  Future<void> _sendRegistration(String token) async {
    try {
      await _apiClient.post(_devicesPath, {
        'fcmToken': token,
        'platform': _platform,
        'deviceName': await _deviceName(),
      });
      debugPrint('[DeviceRegistration] Registered device token.');
    } catch (e, st) {
      debugPrint('[DeviceRegistration] send failed: $e\n$st');
    }
  }

  Future<bool> _hasSession() async {
    final jwt = await _tokenStorage.getToken();
    return jwt != null && jwt.isNotEmpty;
  }

  /// Removes this device's token from the backend. Must run while the JWT is
  /// still present. Best-effort — a failure must not block logout.
  Future<void> unregisterBeforeLogout() async {
    if (!_isSupportedPlatform) return;
    try {
      final token = await _resolveFcmToken();
      if (token == null || token.isEmpty) return;
      await _apiClient.delete(
        '$_devicesPath?fcmToken=${Uri.encodeQueryComponent(token)}',
      );
      // Invalidate the local token so a future login mints a fresh one.
      await _messaging.deleteToken();
      debugPrint('[DeviceRegistration] Unregistered device token.');
    } catch (e, st) {
      debugPrint('[DeviceRegistration] unregister failed: $e\n$st');
    }
  }

  Future<String?> _resolveFcmToken() async {
    // On iOS, FCM needs the APNs token first; getToken() handles the wait.
    return _messaging.getToken();
  }

  bool get _isSupportedPlatform => Platform.isAndroid || Platform.isIOS;

  String get _platform => Platform.isIOS ? 'IOS' : 'ANDROID';

  Future<String> _deviceName() async {
    final info = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        final android = await info.androidInfo;
        final name = '${android.manufacturer} ${android.model}'.trim();
        return name.isNotEmpty ? name : 'Android device';
      }
      if (Platform.isIOS) {
        final ios = await info.iosInfo;
        final name = ios.name.trim();
        return name.isNotEmpty ? name : (ios.utsname.machine);
      }
    } catch (_) {}
    return 'Unknown device';
  }
}
