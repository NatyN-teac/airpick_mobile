import 'package:equatable/equatable.dart';

class ChatMessage extends Equatable {
  final String id;
  final String content;
  final String senderId;
  final DateTime sentAt;
  // Optimistic messages that haven't been confirmed by the server yet.
  final bool pending;

  const ChatMessage({
    required this.id,
    required this.content,
    required this.senderId,
    required this.sentAt,
    this.pending = false,
  });

  // Parsed defensively — the REST history and the STOMP payload may differ.
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final sender = json['senderId'] ??
        json['sender'] ??
        json['userId'] ??
        (json['sender'] is Map ? (json['sender'] as Map)['id'] : null);
    final ts = json['createdAt'] ??
        json['sentAt'] ??
        json['timestamp'] ??
        json['createdDate'];
    return ChatMessage(
      id: (json['id'] ?? json['_id'] ?? json['messageId'] ?? '').toString(),
      content: (json['content'] ?? json['message'] ?? json['text'] ?? '')
          .toString(),
      senderId: (sender ?? '').toString(),
      sentAt: _parseDate(ts),
    );
  }

  static DateTime _parseDate(dynamic v) {
    if (v == null) return DateTime.now();
    if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
    return DateTime.tryParse(v.toString())?.toLocal() ?? DateTime.now();
  }

  ChatMessage copyWith({String? id, bool? pending}) => ChatMessage(
        id: id ?? this.id,
        content: content,
        senderId: senderId,
        sentAt: sentAt,
        pending: pending ?? this.pending,
      );

  @override
  List<Object?> get props => [id, content, senderId, sentAt, pending];
}
