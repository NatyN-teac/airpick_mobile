import 'package:equatable/equatable.dart';
import '../../matches/models/match_models.dart';
import '../models/chat.dart';
import '../models/chat_message.dart';
import '../service/chat_socket.dart';

enum ChatStatus { loading, ready, error }

class ChatState extends Equatable {
  final ChatStatus status;
  final String? error;
  final String? chatId;
  final String currentUserId;
  final List<ChatMessage> messages;
  final MatchContext? context;
  final ChatConnState connState;
  // Match details (items + status) — fetched separately from the chat room.
  final MatchResponse? match;
  final bool isCarrier;
  final bool pickingUp;

  const ChatState({
    this.status = ChatStatus.loading,
    this.error,
    this.chatId,
    this.currentUserId = '',
    this.messages = const [],
    this.context,
    this.connState = ChatConnState.connecting,
    this.match,
    this.isCarrier = false,
    this.pickingUp = false,
  });

  bool isMine(ChatMessage m) => m.senderId == currentUserId;

  // Carrier can confirm pickup once — match is accepted and no photo yet.
  bool get canPickUp =>
      isCarrier &&
      match != null &&
      match!.status == 'ACCEPTED' &&
      !match!.hasPickupPhoto;

  bool get pickupComplete => match?.hasPickupPhoto ?? false;

  bool get inDelivery =>
      pickupComplete ||
      match?.status == 'IN_PROGRESS' ||
      match?.status == 'IN_DELIVERY';

  int get itemCount => match?.matchedItems.length ?? context?.itemCount ?? 0;

  String? get displayStatus => match?.status ?? context?.status;

  String? get routeLabel {
    final from = match?.pickupArea?.trim().isNotEmpty == true
        ? match!.pickupArea
        : context?.fromLabel;
    final to = match?.deliveryArea?.trim().isNotEmpty == true
        ? match!.deliveryArea
        : context?.toLabel;
    if (from != null &&
        from.isNotEmpty &&
        to != null &&
        to.isNotEmpty) {
      return '$from  →  $to';
    }
    return from?.isNotEmpty == true
        ? from
        : (to?.isNotEmpty == true ? to : null);
  }

  String get itemSummary {
    final items = match?.matchedItems ?? const [];
    if (items.isEmpty) {
      return itemCount > 0 ? '$itemCount item${itemCount == 1 ? '' : 's'}' : 'Loading items…';
    }
    if (items.length == 1) {
      return items.first.itemName;
    }
    return '${items.first.itemName} +${items.length - 1} more';
  }

  double get totalPrice => match?.totalPrice ?? 0;

  ChatState copyWith({
    ChatStatus? status,
    String? error,
    String? chatId,
    String? currentUserId,
    List<ChatMessage>? messages,
    MatchContext? context,
    ChatConnState? connState,
    MatchResponse? match,
    bool? isCarrier,
    bool? pickingUp,
  }) =>
      ChatState(
        status: status ?? this.status,
        error: error,
        chatId: chatId ?? this.chatId,
        currentUserId: currentUserId ?? this.currentUserId,
        messages: messages ?? this.messages,
        context: context ?? this.context,
        connState: connState ?? this.connState,
        match: match ?? this.match,
        isCarrier: isCarrier ?? this.isCarrier,
        pickingUp: pickingUp ?? this.pickingUp,
      );

  @override
  List<Object?> get props => [
        status, error, chatId, currentUserId, messages, context, connState,
        match, isCarrier, pickingUp,
      ];
}
