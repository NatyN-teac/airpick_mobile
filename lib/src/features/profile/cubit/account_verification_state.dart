part of 'account_verification_cubit.dart';

enum AccountVerificationStatus { initial, loading, loaded, failure }

/// Network action in flight; drives button spinners.
enum VerificationAction { none, starting, uploading, submitting }

/// A problem the screen should tell the user about. Mapped to translated
/// text in the UI; [VerificationIssue.generic] falls back to the server text.
enum VerificationIssue {
  appUpdateRequired,
  alreadyInProgress,
  locked,
  cooldown,
  sessionExpired,
  invalidFile,
  filesMissing,
  generic,
}

class AccountVerificationState {
  final AccountVerificationStatus status;
  final AccountVerification? verification;

  /// Open attempt being captured; null until POST /session succeeds.
  final VerificationSession? session;

  /// Set when the server resumed an open attempt whose document type differs
  /// from the one the user just picked.
  final VerificationDocumentType? resumedDocumentType;

  final VerificationAction action;
  final VerificationFileKind? uploadingKind;

  final VerificationIssue? issue;

  /// Server message for [VerificationIssue.generic].
  final String? issueMessage;

  /// Bumped on every new issue so listeners fire even for a repeat issue.
  final int issueSeq;

  final String? error;

  const AccountVerificationState({
    this.status = AccountVerificationStatus.initial,
    this.verification,
    this.session,
    this.resumedDocumentType,
    this.action = VerificationAction.none,
    this.uploadingKind,
    this.issue,
    this.issueMessage,
    this.issueSeq = 0,
    this.error,
  });

  bool get isBusy => action != VerificationAction.none;

  AccountVerificationState copyWith({
    AccountVerificationStatus? status,
    AccountVerification? verification,
    VerificationSession? session,
    bool clearSession = false,
    VerificationDocumentType? resumedDocumentType,
    bool clearResumedDocumentType = false,
    VerificationAction? action,
    VerificationFileKind? uploadingKind,
    String? error,
    bool clearError = false,
  }) =>
      AccountVerificationState(
        status: status ?? this.status,
        verification: verification ?? this.verification,
        session: clearSession ? null : (session ?? this.session),
        resumedDocumentType: clearResumedDocumentType || clearSession
            ? null
            : (resumedDocumentType ?? this.resumedDocumentType),
        action: action ?? this.action,
        // Only meaningful while uploading; reset with every other action.
        uploadingKind: (action ?? this.action) == VerificationAction.uploading
            ? (uploadingKind ?? this.uploadingKind)
            : null,
        issue: issue,
        issueMessage: issueMessage,
        issueSeq: issueSeq,
        error: clearError ? null : (error ?? this.error),
      );

  AccountVerificationState withIssue(
    VerificationIssue issue, {
    String? message,
  }) =>
      AccountVerificationState(
        status: status,
        verification: verification,
        session: session,
        resumedDocumentType: resumedDocumentType,
        action: VerificationAction.none,
        issue: issue,
        issueMessage: message,
        issueSeq: issueSeq + 1,
        error: error,
      );
}
