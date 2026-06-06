import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/models/user_model.dart';
import '../../settings/repository/settings_repository.dart';
import '../models/profile_snapshot.dart';

// Holds the signed-in user's profile snapshot (persisted, so it survives
// restarts without a /users/me endpoint).
class CurrentUserCubit extends Cubit<ProfileSnapshot?> {
  final SettingsRepository _settings;

  CurrentUserCubit(this._settings) : super(_settings.getProfile());

  void setFromUser(UserModel user) {
    final snap = ProfileSnapshot.fromUser(user);
    emit(snap);
    _settings.saveProfile(snap);
  }

  void updateProfile(ProfileSnapshot profile) {
    emit(profile);
    _settings.saveProfile(profile);
  }

  void updateVerification({required bool isVerified, String? status}) {
    final current = state;
    if (current == null) return;
    emit(current.copyWith(
      isVerified: isVerified,
      verificationStatus: status,
    ));
    _settings.saveProfile(state!);
  }

  void clear() {
    emit(null);
    _settings.clearProfile();
  }
}
