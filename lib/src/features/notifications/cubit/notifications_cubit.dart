import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/app_refresh_bus.dart';
import '../repository/notification_repository.dart';
import 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final NotificationRepository _repo;
  StreamSubscription<void>? _refreshSub;

  NotificationsCubit(this._repo) : super(const NotificationsState()) {
    // A push arriving while the app is open should bump the unread badge and
    // refresh the inbox — the FCM handler broadcasts this topic.
    _refreshSub =
        AppRefreshBus.instance.on(RefreshTopic.notifications).listen((_) {
      refresh();
    });
  }

  @override
  Future<void> close() {
    _refreshSub?.cancel();
    return super.close();
  }

  /// Loads the inbox from the backend. Called once on creation and on refresh.
  Future<void> load() async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final items = await _repo.fetch();
      emit(state.copyWith(items: items, loading: false));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  /// Pull-to-refresh handler.
  Future<void> refresh() => load();

  /// Marks one notification read — optimistic, then persisted. A failed request
  /// leaves the optimistic state; the next refresh re-syncs with the server.
  Future<void> markRead(String id) async {
    emit(state.copyWith(
      items: state.items
          .map((n) => n.id == id ? n.copyWith(read: true) : n)
          .toList(),
    ));
    try {
      await _repo.markRead(id);
    } catch (_) {/* keep optimistic state; re-syncs on next refresh */}
  }

  /// Marks every notification read — optimistic, then persisted.
  Future<void> markAllRead() async {
    emit(state.copyWith(
      items: state.items.map((n) => n.copyWith(read: true)).toList(),
    ));
    try {
      await _repo.markAllRead();
    } catch (_) {/* keep optimistic state; re-syncs on next refresh */}
  }
}
