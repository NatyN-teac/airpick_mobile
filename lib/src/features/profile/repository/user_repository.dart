import '../../../core/network/api_client.dart';
import '../../home/cubit/user_mode_cubit.dart';

class UserRepository {
  final ApiClient _client;

  UserRepository(this._client);

  // PATCH /api/v1/users/update-mode { "mode": "CARRIER" }
  // Returns the new active mode from the updated user.
  Future<UserMode> updateMode(UserMode mode) async {
    final response = await _client.patch(
      '/users/update-mode',
      {'mode': mode.apiValue},
    );
    final data = (response['content'] ?? response['data']) as Map<String, dynamic>?;
    final active = data?['activeMode'] as String?;
    return active != null ? UserModeX.fromApi(active) : mode;
  }
}
