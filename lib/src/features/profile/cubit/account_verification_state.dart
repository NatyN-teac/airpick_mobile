part of 'account_verification_cubit.dart';

enum AccountVerificationStatus {
  initial,
  loading,
  startingVeriff,
  pollingStatus,
  loaded,
  failure,
}

class AccountVerificationState {
  final AccountVerificationStatus status;
  final AccountVerification? verification;
  final String? error;

  const AccountVerificationState({
    this.status = AccountVerificationStatus.initial,
    this.verification,
    this.error,
  });

  AccountVerificationState copyWith({
    AccountVerificationStatus? status,
    AccountVerification? verification,
    String? error,
    bool clearError = false,
  }) =>
      AccountVerificationState(
        status: status ?? this.status,
        verification: verification ?? this.verification,
        error: clearError ? null : (error ?? this.error),
      );
}
