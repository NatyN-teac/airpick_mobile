import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../models/app_notification.dart';

/// Talks to the notification inbox API (`/api/v1/notifications`).
///
/// Notifications are persisted server-side; the app loads them on start, marks
/// them read as the user views them, and re-fetches on pull-to-refresh.
class NotificationRepository {
  final ApiClient _client;

  NotificationRepository(this._client);

  // GET /api/v1/notifications?page=&size= — inbox, newest first.
  Future<List<AppNotification>> fetch({int page = 0, int size = 30}) async {
    final response = await _client.get('/notifications?page=$page&size=$size');
    if (response['success'] == false) {
      throw Exception(
        apiResponseMessage(response) ?? 'Failed to load notifications.',
      );
    }
    final list = (response['content'] ?? response['data'] ?? []) as List<dynamic>;
    return list
        .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // PATCH /api/v1/notifications/{id}/read — mark a single notification read.
  Future<void> markRead(String id) async {
    await _client.patchVoid('/notifications/$id/read');
  }

  // PATCH /api/v1/notifications/read-all — mark every notification read.
  Future<void> markAllRead() async {
    await _client.patchVoid('/notifications/read-all');
  }
}
