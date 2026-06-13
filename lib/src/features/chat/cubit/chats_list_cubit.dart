import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/chat_summary.dart';
import '../repository/chat_repository.dart';
import 'chats_list_state.dart';

class ChatsListCubit extends Cubit<ChatsListState> {
  ChatsListCubit(ChatRepository _) : super(const ChatsListState());

  Future<void> load({bool force = false}) async {
    // The backend currently has no GET /chats inbox endpoint. Chat rows are
    // derived from accepted matches in EngagementCubit instead.
  }

  Future<void> reload() => load(force: true);

  void clearUnreadForMatch(String matchId) {
    final updated = state.chats
        .map(
          (c) => c.matchId == matchId
              ? ChatSummary(
                  matchId: c.matchId,
                  title: c.title,
                  otherPartyName: c.otherPartyName,
                  otherPartyAvatarUrl: c.otherPartyAvatarUrl,
                  lastMessage: c.lastMessage,
                  lastMessageAt: c.lastMessageAt,
                  unreadCount: 0,
                )
              : c,
        )
        .toList();
    emit(state.copyWith(chats: updated));
  }
}
