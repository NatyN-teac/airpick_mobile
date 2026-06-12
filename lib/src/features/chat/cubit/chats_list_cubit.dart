import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/chat_summary.dart';
import '../repository/chat_repository.dart';
import 'chats_list_state.dart';

class ChatsListCubit extends Cubit<ChatsListState> {
  final ChatRepository _repo;
  bool _loadedOnce = false;

  ChatsListCubit(this._repo) : super(const ChatsListState());

  Future<void> load({bool force = false}) async {
    if (_loadedOnce && !force) return;
    emit(state.copyWith(loading: true, error: null));
    try {
      final chats = await _repo.fetchChats();
      _loadedOnce = true;
      emit(state.copyWith(chats: chats, loading: false));
    } catch (e) {
      emit(state.copyWith(
        loading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
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
