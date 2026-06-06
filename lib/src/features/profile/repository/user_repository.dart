import 'dart:io';

import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../../home/cubit/user_mode_cubit.dart';
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

  Future<AccountVerification> getAccountVerification(String userId) async {
    final response = await _client.get('/users/$userId/verify-user');
    final data = _unwrap(response) ?? response;
    return AccountVerification.fromJson(data);
  }

  Future<AccountVerification> uploadPassport(
    String userId,
    File imageFile,
  ) async {
    final formData = FormData.fromMap({
      'passport': await MultipartFile.fromFile(
        imageFile.path,
        filename: 'passport.jpg',
      ),
    });
    await _client.postMultipart(
      '/users/$userId/upload-passport',
      formData,
    );
    return getAccountVerification(userId);
  }

  Future<ClosedAccountResponse> closeAccount(String userId) async {
    final response = await _client.post('/users/$userId/close', {});
    final data = _unwrap(response) ?? response;
    return ClosedAccountResponse.fromJson(data);
  }
}
