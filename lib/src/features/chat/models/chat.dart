import 'chat_message.dart';

class ChatParticipant {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? profilePictureUrl;

  const ChatParticipant({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.profilePictureUrl,
  });

  factory ChatParticipant.fromJson(Map<String, dynamic> json) =>
      ChatParticipant(
        id: (json['id'] ?? '').toString(),
        firstName: (json['firstName'] ?? '').toString(),
        lastName: (json['lastName'] ?? '').toString(),
        email: (json['email'] ?? '').toString(),
        profilePictureUrl: json['profilePictureUrl'] as String?,
      );

  String get displayName {
    final name =
        [firstName, lastName].where((p) => p.trim().isNotEmpty).join(' ').trim();
    return name.isEmpty ? 'User' : name;
  }
}

class ChatReceiverInfo {
  final bool receiverNeeded;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? photoIdUrl;
  final bool isActive;

  const ChatReceiverInfo({
    required this.receiverNeeded,
    this.firstName,
    this.lastName,
    this.phone,
    this.photoIdUrl,
    this.isActive = true,
  });

  factory ChatReceiverInfo.fromJson(Map<String, dynamic> json) =>
      ChatReceiverInfo(
        receiverNeeded: json['receiverNeeded'] as bool? ?? false,
        firstName: json['firstName'] as String?,
        lastName: json['lastName'] as String?,
        phone: json['phone'] as String?,
        photoIdUrl: json['photoIdUrl'] as String?,
        isActive: json['isActive'] as bool? ?? true,
      );
}

// Header context derived from GET /chats/match/{matchId}.
class MatchContext {
  final String? otherPartyName;
  final String? otherPartyAvatarUrl;
  final String? fromLabel;
  final String? toLabel;
  final String? status;
  final int itemCount;

  const MatchContext({
    this.otherPartyName,
    this.otherPartyAvatarUrl,
    this.fromLabel,
    this.toLabel,
    this.status,
    this.itemCount = 0,
  });

  MatchContext copyWith({
    String? otherPartyName,
    String? otherPartyAvatarUrl,
    String? fromLabel,
    String? toLabel,
    String? status,
    int? itemCount,
  }) =>
      MatchContext(
        otherPartyName: otherPartyName ?? this.otherPartyName,
        otherPartyAvatarUrl: otherPartyAvatarUrl ?? this.otherPartyAvatarUrl,
        fromLabel: fromLabel ?? this.fromLabel,
        toLabel: toLabel ?? this.toLabel,
        status: status ?? this.status,
        itemCount: itemCount ?? this.itemCount,
      );
}

/// ChatRoomResponseDto — GET /api/v1/chats/match/{matchId}
class Chat {
  final String chatId;
  final String matchId;
  final String matchStatus;
  final ChatParticipant? carrier;
  final ChatParticipant? shipper;
  final ChatReceiverInfo? receiver;
  final int totalUnreadCount;
  final List<ChatMessage> messages;
  final String? createdAt;

  const Chat({
    required this.chatId,
    required this.matchId,
    required this.matchStatus,
    required this.totalUnreadCount,
    required this.messages,
    this.carrier,
    this.shipper,
    this.receiver,
    this.createdAt,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    ChatParticipant? participant(dynamic raw) =>
        raw is Map<String, dynamic> ? ChatParticipant.fromJson(raw) : null;

    final rawMessages = json['messages'] as List<dynamic>? ?? [];
    return Chat(
      chatId: (json['chatId'] ?? '').toString(),
      matchId: (json['matchId'] ?? '').toString(),
      matchStatus: (json['matchStatus'] ?? '').toString(),
      carrier: participant(json['carrier']),
      shipper: participant(json['shipper']),
      receiver: json['receiver'] is Map<String, dynamic>
          ? ChatReceiverInfo.fromJson(
              json['receiver'] as Map<String, dynamic>,
            )
          : null,
      totalUnreadCount: (json['totalUnreadCount'] as num?)?.toInt() ?? 0,
      messages: rawMessages
          .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.sentAt.compareTo(b.sentAt)),
      createdAt: json['createdAt']?.toString(),
    );
  }

  MatchContext contextForUser(String currentUserId) {
    ChatParticipant? other;
    if (carrier != null && carrier!.id == currentUserId) {
      other = shipper;
    } else if (shipper != null && shipper!.id == currentUserId) {
      other = carrier;
    } else {
      other = shipper ?? carrier;
    }

    return MatchContext(
      otherPartyName: other?.displayName,
      otherPartyAvatarUrl: other?.profilePictureUrl,
      status: matchStatus.isNotEmpty ? matchStatus : null,
    );
  }
}
