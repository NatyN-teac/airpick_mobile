import 'dart:async';

/// Lightweight app-wide signal for "something changed, dependent lists should
/// reload". Long-lived cubits (e.g. [EngagementCubit]) subscribe to the topics
/// they care about; mutating actions elsewhere in the app broadcast a topic
/// after a successful write so those cubits refresh without needing the cubit
/// in their own widget subtree.
///
/// This keeps the fix targeted: callers just fire a topic, subscribers just
/// reload — no provider re-plumbing across route boundaries.
enum RefreshTopic {
  /// A proposal was sent / withdrawn / accepted / rejected — engagements changed.
  engagements,

  /// An airport was added — airport pickers should re-fetch.
  airports,
}

class AppRefreshBus {
  AppRefreshBus._();
  static final AppRefreshBus instance = AppRefreshBus._();

  final _controller = StreamController<RefreshTopic>.broadcast();

  /// Emits when any topic is fired. Subscribers filter to the topics they want.
  Stream<RefreshTopic> get stream => _controller.stream;

  /// Emits only the given [topic].
  Stream<void> on(RefreshTopic topic) =>
      _controller.stream.where((t) => t == topic);

  void emit(RefreshTopic topic) {
    if (!_controller.isClosed) _controller.add(topic);
  }
}
