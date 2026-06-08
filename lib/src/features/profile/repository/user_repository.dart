import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../../home/cubit/user_mode_cubit.dart';
import '../../home/models/engagement_models.dart';
import '../models/account_verification.dart';
import '../models/user_profile_detail.dart';

class UserRepository {
  final ApiClient _client;

  UserRepository(this._client);

  Map<String, dynamic>? _unwrap(Map<String, dynamic> response) {
    final raw = response['content'] ?? response['data'];
    if (raw is Map<String, dynamic>) return raw;
    return null;
  }

  UserProfileDetail _parseProfileDetail(Map<String, dynamic> response) {
    if (response['success'] == false) {
      throw Exception(
        apiResponseMessage(response) ?? 'Failed to load profile.',
      );
    }
    final content = _unwrap(response);
    if (content == null) {
      throw Exception(
        apiResponseMessage(response) ?? 'Profile not found.',
      );
    }
    return UserProfileDetail.fromJson(content);
  }

  // PATCH /api/v1/users/update-mode { "mode": "CARRIER" }
  Future<UserMode> updateMode(UserMode mode) async {
    final response = await _client.patch(
      '/users/update-mode',
      {'mode': mode.apiValue},
    );
    final data = _unwrap(response);
    final active = data?['activeMode'] as String?;
    return active != null ? UserModeX.fromApi(active) : mode;
  }

  // GET /api/v1/users/{userId}/profile
  Future<UserProfileDetail> getUserProfile(String userId) async {
    final response = await _client.get('/users/$userId/profile');
    return _parseProfileDetail(response);
  }

  // PUT /api/v1/users/update
  Future<UserProfileDetail> updateUserProfile(
    UpdateUserProfileRequest request,
  ) async {
    final response = await _client.put('/users/update', request.toJson());
    return _parseProfileDetail(response);
  }

  // GET /api/v1/users/engagement — proposals + matches for home (mode-aware).
  Future<EngagementResponse> fetchEngagement() async {
    final response = await _client.get('/users/engagement');
    if (response['success'] == false) {
      throw Exception(
        apiResponseMessage(response) ?? 'Failed to load engagements.',
      );
    }
    final content = _unwrap(response);
    if (content == null) {
      throw Exception('Engagement data missing from server response.');
    }
    return EngagementResponse.fromJson(content);
  }

  Future<ClosedAccountResponse> closeAccount(String userId) async {
    final response = await _client.post('/users/$userId/close', {});
    final data = _unwrap(response) ?? response;
    return ClosedAccountResponse.fromJson(data);
  }

  // POST /api/v1/users/verification/session — JWT identifies user, no body.
  Future<VeriffSession> createVerificationSession() async {
    const path = '/users/verification/session';
    try {
      final response = await _client.post(path, const {});
      logApi(
        tag: 'Verification',
        method: 'POST',
        path: path,
        statusCode: 201,
        body: response,
      );
      if (response['success'] == false) {
        throw Exception(
          apiResponseMessage(response) ??
              'Could not start verification.\n${formatApiResponseBody(response)}',
        );
      }
      final data = _unwrap(response);
      if (data == null) {
        throw Exception(
          'Veriff session missing from server response.\n${formatApiResponseBody(response)}',
        );
      }
      final session = VeriffSession.fromJson(data);
      if (session.sessionUrl.isEmpty) {
        throw Exception(
          'Veriff session URL missing.\n${formatApiResponseBody(response)}',
        );
      }
      return session;
    } catch (e, st) {
      logApi(
        tag: 'Verification',
        method: 'POST',
        path: path,
        error: '$e\n$st',
      );
      rethrow;
    }
  }

  // GET /api/v1/users/verification/status
  Future<VerificationStatusResponse> getVerificationStatus() async {
    const path = '/users/verification/status';
    try {
      final response = await _client.get(path);
      logApi(
        tag: 'Verification',
        method: 'GET',
        path: path,
        statusCode: 200,
        body: response,
      );
      if (response['success'] == false) {
        throw Exception(
          apiResponseMessage(response) ??
              'Could not load verification status.\n${formatApiResponseBody(response)}',
        );
      }
      final data = _unwrap(response);
      if (data == null) {
        throw Exception(
          'Verification status missing.\n${formatApiResponseBody(response)}',
        );
      }
      return VerificationStatusResponse.fromJson(data);
    } catch (e, st) {
      logApi(
        tag: 'Verification',
        method: 'GET',
        path: path,
        error: '$e\n$st',
      );
      rethrow;
    }
  }
}
