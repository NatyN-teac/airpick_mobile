import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/app_notification.dart';
import 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit() : super(const NotificationsState());

  void markAllRead() {
    emit(state.copyWith(
      items: state.items.map((n) => n.copyWith(read: true)).toList(),
    ));
  }

  void markRead(String id) {
    emit(state.copyWith(
      items: state.items
          .map((n) => n.id == id ? n.copyWith(read: true) : n)
          .toList(),
    ));
  }

  /// Placeholder until GET /notifications is wired.
  void setItems(List<AppNotification> items) {
    emit(state.copyWith(items: items));
  }

  /// Pull-to-refresh handler. Re-fetches notifications.
  /// TODO: wire to GET /notifications; for now it just clears any error and
  /// completes so the refresh gesture resolves.
  Future<void> refresh() async {
    emit(state.copyWith(loading: true, error: null));
    await Future<void>.delayed(const Duration(milliseconds: 600));
    emit(state.copyWith(loading: false));
  }
}
