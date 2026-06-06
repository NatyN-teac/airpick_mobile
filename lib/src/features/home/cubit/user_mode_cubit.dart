import 'package:flutter_bloc/flutter_bloc.dart';
import '../../profile/repository/user_repository.dart';
import '../../settings/repository/settings_repository.dart';

enum UserMode { sender, carrier }

extension UserModeX on UserMode {
  String get label => this == UserMode.sender ? 'Sender' : 'Carrier';
  String get pillLabel => this == UserMode.sender ? 'Sender mode' : 'Carrier mode';
  String get description => this == UserMode.sender
      ? 'I need items delivered'
      : "I'm traveling & can carry items";
  String get apiValue => this == UserMode.sender ? 'SENDER' : 'CARRIER';

  static UserMode fromApi(String v) =>
      v.toUpperCase() == 'CARRIER' ? UserMode.carrier : UserMode.sender;
}

class UserModeCubit extends Cubit<UserMode> {
  final SettingsRepository _settings;
  final UserRepository _users;

  UserModeCubit(this._settings, this._users)
      : super(_settings.getMode());

  // Optimistic: update UI + local prefs immediately, then sync to the backend.
  Future<void> setMode(UserMode mode) async {
    if (state == mode) return;
    final previous = state;
    emit(mode);
    await _settings.saveMode(mode);
    try {
      final active = await _users.updateMode(mode);
      if (active != mode) {
        emit(active);
        await _settings.saveMode(active);
      }
    } catch (e) {
      // Roll back on failure so local + server stay consistent.
      print('[UserModeCubit] updateMode failed: $e');
      emit(previous);
      await _settings.saveMode(previous);
    }
  }
}
