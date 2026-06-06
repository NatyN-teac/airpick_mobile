import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/storage/token_storage.dart';
import '../cubit/current_user_cubit.dart';
import '../models/account_verification.dart';
import '../repository/user_repository.dart';

part 'account_verification_state.dart';

class AccountVerificationCubit extends Cubit<AccountVerificationState> {
  final UserRepository _users;
  final TokenStorage _tokens;
  final CurrentUserCubit _profile;

  AccountVerificationCubit(this._users, this._tokens, this._profile)
      : super(const AccountVerificationState());

  Future<void> load() async {
    emit(state.copyWith(
      status: AccountVerificationStatus.loading,
      clearError: true,
    ));
    try {
      final userId = await _requireUserId();
      final verification = await _users.getAccountVerification(userId);
      _syncProfile(verification);
      emit(state.copyWith(
        status: AccountVerificationStatus.loaded,
        verification: verification,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AccountVerificationStatus.failure,
        error: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  Future<void> uploadPassport(File file) async {
    emit(state.copyWith(
      status: AccountVerificationStatus.uploading,
      clearError: true,
    ));
    try {
      final userId = await _requireUserId();
      final verification = await _users.uploadPassport(userId, file);
      _syncProfile(verification);
      emit(state.copyWith(
        status: AccountVerificationStatus.loaded,
        verification: verification,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AccountVerificationStatus.loaded,
        error: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  Future<String> _requireUserId() async {
    final id = await _tokens.getUserId();
    if (id == null || id.isEmpty) {
      throw Exception('User ID not found.');
    }
    return id;
  }

  void _syncProfile(AccountVerification verification) {
    _profile.updateVerification(
      isVerified: verification.isVerified || verification.isApproved,
      status: verification.verificationStatus,
    );
  }
}
