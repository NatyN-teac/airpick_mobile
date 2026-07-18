import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../core/storage/token_storage.dart';
import '../../../core/utils/app_refresh_bus.dart';
import '../../matches/repository/match_repository.dart';
import '../../matches/models/match_models.dart';
import '../models/chat.dart';
import '../models/chat_message.dart';
import '../repository/chat_repository.dart';
import '../service/chat_socket.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository _repo;
  final ChatSocket _socket;
  final MatchRepository _matches;
  final TokenStorage _tokenStorage;
  final String matchId;
  final String? welcomeMessage;
  final MatchResponse? initialMatch;
  final _uuid = const Uuid();

  ChatCubit({
    required ChatRepository repo,
    required ChatSocket socket,
    required MatchRepository matches,
    required TokenStorage tokenStorage,
    required this.matchId,
    this.welcomeMessage,
    this.initialMatch,
  })  : _repo = repo,
        _socket = socket,
        _matches = matches,
        _tokenStorage = tokenStorage,
        super(ChatState(match: initialMatch));

  // Steps 1-4 of the backend guide.
  Future<void> open() async {
    emit(state.copyWith(status: ChatStatus.loading, clearError: true));
    try {
      final userId = await _tokenStorage.getUserId() ?? '';
      final usedCachedMatch = initialMatch?.hasAvailableChat == true;
      final match =
          usedCachedMatch ? initialMatch! : await _matches.getMatch(matchId);
      if (!match.hasAvailableChat) {
        // A freshly-created match is PENDING until the carrier accepts it — the
        // chat room doesn't exist yet, so there's nothing to connect to. Show a
        // friendly "waiting for the carrier" state instead of a connection error.
        if (match.status.toUpperCase() == 'PENDING') {
          emit(state.copyWith(
            status: ChatStatus.pending,
            match: match,
            currentUserId: userId,
            isCarrier: match.carrierId == userId,
            clearError: true,
          ));
          return;
        }
        // A cancelled match keeps its chat room — let the user view the history
        // read-only rather than erroring. Anything else (e.g. REJECTED) has no
        // chat to show.
        final cancelledWithChat = match.status.toUpperCase() == 'CANCELLED' &&
            (match.chatId?.trim().isNotEmpty ?? false);
        if (!cancelledWithChat) {
          throw Exception('Chat is not available for this match.');
        }
      }
      final chat = await _repo.getChatByMatch(matchId);
      debugPrint(
          '[Chat] history loaded: chatId=${chat.chatId}, messages=${chat.messages.length}, userId=$userId');
      emit(state.copyWith(
        status: ChatStatus.ready,
        chatId: chat.chatId,
        currentUserId: userId,
        messages: chat.messages,
        context: _enrichedContext(
          chat.contextForUser(userId),
          match,
        ),
        isCarrier: chat.carrier != null && chat.carrier!.id == userId,
        match: match,
        clearError: true,
      ));
      // 2. mark read (best-effort)
      if (chat.chatId.isNotEmpty) {
        _repo.markRead(chat.chatId).catchError((_) {});
      }
      // Refresh details when navigation supplied a cached match snapshot.
      if (usedCachedMatch) _loadMatch();
      // 3 + 4. connect + subscribe
      await _socket.connect(
        matchId: matchId,
        onMessage: _onIncoming,
        onState: (s) => emit(state.copyWith(connState: s)),
      );
      await _sendWelcomeIfNeeded();
    } catch (e) {
      emit(state.copyWith(
          status: ChatStatus.error,
          error: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _loadMatch() async {
    try {
      final match = await _matches.getMatch(matchId);
      if (isClosed) return;
      emit(state.copyWith(
        match: match,
        context: _enrichedContext(state.context, match),
      ));
    } catch (e) {
      debugPrint('[Chat] could not load match: $e');
      if (!isClosed && state.match == null) {
        emit(state.copyWith(
          error: 'Could not load match items. Pull to retry from chat list.',
        ));
      }
    }
  }

  MatchContext? _enrichedContext(MatchContext? ctx, MatchResponse? match) {
    if (ctx == null || match == null) return ctx;
    return ctx.copyWith(
      status: match.status.isNotEmpty ? match.status : ctx.status,
      itemCount: match.matchedItems.length,
      fromLabel: match.pickupArea?.trim().isNotEmpty == true
          ? match.pickupArea
          : ctx.fromLabel,
      toLabel: match.deliveryArea?.trim().isNotEmpty == true
          ? match.deliveryArea
          : ctx.toLabel,
    );
  }

  // Carrier confirms pickup with a photo — once per match.
  Future<void> startPickup({required String photoPath}) async {
    if (!state.canPickUp || state.pickingUp) return;
    emit(state.copyWith(pickingUp: true, clearError: true));
    try {
      final updated =
          await _matches.uploadPickupPhoto(matchId, File(photoPath));
      emit(state.copyWith(
        pickingUp: false,
        match: updated,
        context: _enrichedContext(state.context, updated),
      ));
      // The delivery list's pickup stage is now stale — tell it to re-fetch.
      AppRefreshBus.instance.emit(RefreshTopic.deliveries);
    } catch (e) {
      emit(state.copyWith(
          pickingUp: false,
          error: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  void _onIncoming(ChatMessage msg) {
    // Ignore exact duplicates (already have this id).
    if (state.messages.any((m) => m.id == msg.id && !m.pending)) return;

    // Reconcile an optimistic message of mine with the server echo.
    final idx = state.messages.indexWhere((m) =>
        m.pending && m.senderId == msg.senderId && m.content == msg.content);
    final updated = [...state.messages];
    if (idx != -1) {
      updated[idx] = msg;
    } else {
      updated.add(msg);
    }
    updated.sort((a, b) => a.sentAt.compareTo(b.sentAt));
    emit(state.copyWith(messages: updated));
  }

  Future<void> _sendWelcomeIfNeeded() async {
    final text = welcomeMessage?.trim();
    if (text == null || text.isEmpty) return;
    if (state.messages.isNotEmpty) return;
    await Future.delayed(const Duration(milliseconds: 350));
    if (isClosed) return;
    send(text);
  }

  // Step 5 — optimistic append, server echo reconciles.
  void send(String content) {
    if (state.isReadOnly) return; // delivered/cancelled — view-only
    final text = content.trim();
    if (text.isEmpty) return;
    if (state.connState != ChatConnState.connected) {
      emit(state.copyWith(
        error: 'Still connecting to chat. Wait a moment and try again.',
      ));
      return;
    }

    final optimistic = ChatMessage(
      id: 'tmp_${_uuid.v4()}',
      content: text,
      senderId: state.currentUserId,
      sentAt: DateTime.now(),
      pending: true,
    );
    emit(state.copyWith(
      messages: [...state.messages, optimistic],
      clearError: true,
    ));
    try {
      _socket.send(text);
    } catch (e) {
      final withoutPending =
          state.messages.where((m) => m.id != optimistic.id).toList();
      emit(state.copyWith(
        messages: withoutPending,
        error: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  Future<void> retry() => open();

  @override
  Future<void> close() async {
    await _socket.disconnect(); // step 7
    return super.close();
  }
}
