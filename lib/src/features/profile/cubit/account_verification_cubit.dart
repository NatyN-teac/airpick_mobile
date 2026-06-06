import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:veriff_flutter/veriff_flutter.dart';
import '../cubit/current_user_cubit.dart';
import '../models/account_verification.dart';
import '../repository/user_repository.dart';
import '../services/veriff_service.dart';

part 'account_verification_state.dart';

class AccountVerificationCubit extends Cubit<AccountVerificationState> {
  final UserRepository _users;
  final CurrentUserCubit _profile;
  final VeriffService _veriff;

  AccountVerificationCubit(
    this._users,
    this._profile, [
    VeriffService? veriff,
  ])  : _veriff = veriff ?? const VeriffService(),
        super(const AccountVerificationState());

  /// Local snapshot first, then GET /users/verification/status.
  Future<void> load() async {
    final local = AccountVerification.fromProfileSnapshot(_profile.state);
    emit(state.copyWith(
      status: AccountVerificationStatus.loaded,
      verification: local,
      clearError: true,
    ));

    await _refreshStatus(fallback: local);
  }

  /// Creates a Veriff session, launches the SDK, then polls backend status.
  Future<VeriffFlowOutcome> startVeriffVerification({
    required bool isDark,
    String? languageLocale,
  }) async {
    final current =
        state.verification ?? AccountVerification.fromProfileSnapshot(_profile.state);

    emit(state.copyWith(
      status: AccountVerificationStatus.startingVeriff,
      clearError: true,
    ));

    try {
      final session = await _users.createVerificationSession();
      // ignore: avoid_print
      print('[AccountVerificationCubit] Veriff session created: '
          'id=${session.sessionId} url=${session.sessionUrl}');

      emit(state.copyWith(
        status: AccountVerificationStatus.loaded,
        verification: current,
      ));

      final result = await _veriff.startVerification(
        sessionUrl: session.sessionUrl,
        isDark: isDark,
        languageLocale: languageLocale,
      );

      if (result.status == Status.canceled) {
        return VeriffFlowOutcome.canceled;
      }

      if (result.status == Status.error) {
        throw Exception(
          veriffErrorMessage(result.error) ??
              'Verification ended with an error.',
        );
      }

      emit(state.copyWith(status: AccountVerificationStatus.pollingStatus));
      final verification = await _pollVerificationStatus();
      _applyVerification(verification);

      if (verification.isApproved) {
        return VeriffFlowOutcome.verified;
      }
      return VeriffFlowOutcome.submitted;
    } catch (e, st) {
      // ignore: avoid_print
      print('[AccountVerificationCubit] startVeriffVerification failed: $e\n$st');
      emit(state.copyWith(
        status: AccountVerificationStatus.loaded,
        verification: current,
        error: e.toString().replaceFirst('Exception: ', ''),
      ));
      rethrow;
    }
  }

  Future<void> refreshAfterSubmission() => _refreshStatus(
        fallback: state.verification ??
            AccountVerification.fromProfileSnapshot(_profile.state),
      );

  Future<void> _refreshStatus({required AccountVerification fallback}) async {
    try {
      final response = await _users.getVerificationStatus();
      if (isClosed) return;
      _applyVerification(response.toAccountVerification());
    } catch (_) {
      if (!isClosed) {
        emit(state.copyWith(
          status: AccountVerificationStatus.loaded,
          verification: fallback,
        ));
      }
    }
  }

  Future<AccountVerification> _pollVerificationStatus({
    int maxAttempts = 10,
    Duration interval = const Duration(seconds: 2),
  }) async {
    AccountVerification latest =
        state.verification ?? AccountVerification.fromProfileSnapshot(_profile.state);

    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      if (isClosed) break;
      try {
        final response = await _users.getVerificationStatus();
        latest = response.toAccountVerification();
        _applyVerification(latest);

        if (latest.isApproved || latest.isRejected) {
          return latest;
        }

        final s = latest.verificationStatus.toLowerCase();
        if (s == 'submitted' || s == 'review' || s == 'started') {
          if (attempt >= maxAttempts - 1) return latest;
          await Future.delayed(interval);
          continue;
        }

        return latest;
      } catch (_) {
        if (attempt == maxAttempts - 1) rethrow;
        await Future.delayed(interval);
      }
    }

    return latest;
  }

  void _applyVerification(AccountVerification verification) {
    _syncProfile(verification);
    emit(state.copyWith(
      status: AccountVerificationStatus.loaded,
      verification: verification,
      clearError: true,
    ));
  }

  void _syncProfile(AccountVerification verification) {
    _profile.updateVerification(
      isVerified: verification.isApproved,
      status: verification.verificationStatus,
    );
  }
}
