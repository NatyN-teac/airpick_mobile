import 'dart:async';

class AppSession {
  AppSession._();

  static final _unauthorizedController = StreamController<void>.broadcast();

  static Stream<void> get onUnauthorized => _unauthorizedController.stream;

  static void notifyUnauthorized() {
    if (!_unauthorizedController.isClosed) {
      _unauthorizedController.add(null);
    }
  }
}
