import 'dart:async';

import '../../features/auth/data/firebase_auth_service.dart';
import '../storage/token_storage.dart';

class AppSession {
  AppSession._();

  static final _unauthorizedController = StreamController<void>.broadcast();
  static final _blockedController = StreamController<void>.broadcast();
  static bool _expiring = false;

  static Stream<void> get onUnauthorized => _unauthorizedController.stream;

  /// Fires when the backend rejects a call with `403 AUTH_003 USER_BLOCKED`
  /// (e.g. after a SUSPECTED_FRAUD verification decline). The JWT is still
  /// valid, so this does not sign the user out — [AppRouter] shows the
  /// blocked-account screen instead.
  static Stream<void> get onBlocked => _blockedController.stream;

  /// Clears local + Firebase auth once, then notifies [AppRouter] to show sign-in.
  static Future<void> expireSession(TokenStorage tokenStorage) async {
    if (_expiring) return;
    _expiring = true;
    try {
      await tokenStorage.clear();
      try {
        await FirebaseAuthService().signOut();
      } catch (_) {}
      notifyUnauthorized();
    } finally {
      _expiring = false;
    }
  }

  static void notifyUnauthorized() {
    if (!_unauthorizedController.isClosed) {
      _unauthorizedController.add(null);
    }
  }

  static void notifyBlocked() {
    if (!_blockedController.isClosed) {
      _blockedController.add(null);
    }
  }
}
