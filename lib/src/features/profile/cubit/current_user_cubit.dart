import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/notifications/app_notifications.dart';
import '../../../core/storage/token_storage.dart';
import '../../auth/models/user_model.dart';
import '../../settings/repository/settings_repository.dart';
import '../models/profile_snapshot.dart';
import '../models/user_profile_detail.dart';
import '../repository/user_repository.dart';

// Holds the signed-in user's profile snapshot (persisted, so it survives
// restarts without a /users/me endpoint).
class CurrentUserCubit extends Cubit<ProfileSnapshot?> {
  final SettingsRepository _settings;
  int _profileSyncGen = 0;

  CurrentUserCubit(this._settings) : super(_settings.getProfile());

  void setFromUser(UserModel user) {
    updateProfile(ProfileSnapshot.fromUser(user));
  }

  void updateProfile(ProfileSnapshot profile) {
    // Fire a one-off local notification the moment the user becomes verified
    // (false -> true), regardless of which path flipped it (Veriff result or a
    // server refresh).
    final wasVerified = state?.isVerified ?? false;
    if (!wasVerified && profile.isVerified) {
      AppNotifications.verified();
    }
    _profileSyncGen++;
    emit(profile);
    _settings.saveProfile(profile);
  }

  void applySavedDetails({
    required UpdateUserProfileRequest request,
    UserProfileDetail? detail,
    String? emailFallback,
  }) {
    final base = state ?? ProfileSnapshot(email: emailFallback ?? '');
    updateProfile(
      ProfileSnapshot.mergeAfterSave(
        request: request,
        detail: detail,
        current: base,
      ),
    );
  }

  void updateVerification({required bool isVerified, String? status}) {
    final current = state;
    if (current == null) return;
    updateProfile(current.copyWith(
      isVerified: isVerified,
      verificationStatus: status,
    ));
  }

  void clear() {
    _profileSyncGen++;
    emit(null);
    _settings.clearProfile();
  }

  /// Loads the latest profile from GET /users/{id}/profile and merges it
  /// into the persisted snapshot so the profile tab stays in sync.
  Future<void> refreshFromServer(
    UserRepository users,
    TokenStorage tokens,
  ) async {
    final userId = await tokens.getUserId();
    if (userId == null || userId.isEmpty) return;

    final gen = ++_profileSyncGen;
    try {
      final detail = await users.getUserProfile(userId);
      if (isClosed || gen != _profileSyncGen) return;
      final base = state ?? const ProfileSnapshot(email: '');
      updateProfile(ProfileSnapshot.fromDetail(detail, current: base));
    } catch (_) {
      // Keep whatever local snapshot we already have.
    }
  }
}
