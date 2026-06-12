import 'package:equatable/equatable.dart';
import '../models/chat_summary.dart';

class ChatsListState extends Equatable {
  final List<ChatSummary> chats;
  final bool loading;
  final String? error;

  const ChatsListState({
    this.chats = const [],
    this.loading = false,
    this.error,
  });

  int get totalUnread =>
      chats.fold<int>(0, (sum, chat) => sum + chat.unreadCount);

  ChatsListState copyWith({
    List<ChatSummary>? chats,
    bool? loading,
    String? error,
  }) =>
      ChatsListState(
        chats: chats ?? this.chats,
        loading: loading ?? this.loading,
        error: error,
      );

  @override
  List<Object?> get props => [chats, loading, error];
}
