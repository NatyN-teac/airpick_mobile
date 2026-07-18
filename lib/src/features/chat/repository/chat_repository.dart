import 'package:flutter/foundation.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../models/chat.dart';
import '../models/chat_summary.dart';

class ChatRepository {
  final ApiClient _client;

  ChatRepository(this._client);

  // GET /api/v1/chats — the conversation inbox (active first, delivered last).
  Future<List<ChatSummary>> fetchChats() async {
    final response = await _client.get('/chats');
    if (response['success'] == false) {
      throw Exception(
        apiResponseMessage(response) ?? 'Failed to load chats.',
      );
    }
    final list = (response['content'] ?? response['data'] ?? []) as List<dynamic>;
    return list
        .map((e) => ChatSummary.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // GET /api/v1/chats/match/{matchId} — chat room + message history.
  Future<Chat> getChatByMatch(String matchId) async {
    final response = await _client.get('/chats/match/$matchId');
    debugPrint('[Chat] GET /chats/match/$matchId → $response');
    if (response['success'] == false) {
      throw Exception(
        apiResponseMessage(response) ?? 'Failed to load chat room.',
      );
    }
    final data = response['content'] ?? response['data'];
    if (data is! Map<String, dynamic>) {
      throw Exception('Chat room data missing from server response.');
    }
    return Chat.fromJson(data);
  }

  // PATCH /api/v1/chats/{chatId}/read — mark messages read (no body).
  Future<void> markRead(String chatId) async {
    await _client.patchVoid('/chats/$chatId/read');
  }
}
