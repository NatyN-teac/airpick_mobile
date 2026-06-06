import 'profile_snapshot.dart';

/// POST /users/verification/session
class VeriffSession {
  final String sessionId;
  final String sessionUrl;
  final String? sessionToken;
  final String status;

  const VeriffSession({
    required this.sessionId,
    required this.sessionUrl,
    this.sessionToken,
    required this.status,
  });

  factory VeriffSession.fromJson(Map<String, dynamic> json) => VeriffSession(
        sessionId: json['sessionId'] as String? ?? '',
        sessionUrl: json['sessionUrl'] as String? ?? '',
        sessionToken: json['sessionToken'] as String?,
        status: json['status'] as String? ?? 'created',
      );
}

/// GET /users/verification/status
class VerificationStatusResponse {
  final String status;
  final bool isVerified;
  final bool isDenied;
  final String? message;
  final String? veriffSessionId;
  final String? verificationRequestedAt;
  final String? verifiedAt;

  const VerificationStatusResponse({
    required this.status,
    required this.isVerified,
    required this.isDenied,
    this.message,
    this.veriffSessionId,
    this.verificationRequestedAt,
    this.verifiedAt,
  });

  factory VerificationStatusResponse.fromJson(Map<String, dynamic> json) =>
      VerificationStatusResponse(
        status: json['status'] as String? ?? 'NOT_STARTED',
        isVerified: json['isVerified'] as bool? ?? false,
        isDenied: json['isDenied'] as bool? ?? false,
        message: json['message'] as String?,
        veriffSessionId: json['veriffSessionId'] as String?,
        verificationRequestedAt: json['verificationRequestedAt'] as String?,
        verifiedAt: json['verifiedAt'] as String?,
      );

  String get normalizedStatus => status.toUpperCase();

  AccountVerification toAccountVerification() => AccountVerification(
        isVerified: isVerified,
        passportUrl: '',
        verificationStatus: status,
        rejectionReason: isDenied ? message : null,
        message: message,
        veriffSessionId: veriffSessionId,
        verificationRequestedAt: verificationRequestedAt,
        verifiedAt: verifiedAt,
        isDenied: isDenied,
      );
}

class AccountVerification {
  final bool isVerified;
  final String passportUrl;
  final String verificationStatus;
  final String? rejectionReason;
  final int? rejectionCycle;
  final String? message;
  final String? veriffSessionId;
  final String? verificationRequestedAt;
  final String? verifiedAt;
  final bool isDenied;

  const AccountVerification({
    required this.isVerified,
    required this.passportUrl,
    required this.verificationStatus,
    this.rejectionReason,
    this.rejectionCycle,
    this.message,
    this.veriffSessionId,
    this.verificationRequestedAt,
    this.verifiedAt,
    this.isDenied = false,
  });

  String get _status => verificationStatus.toLowerCase();

  bool get isApproved => isVerified || _status == 'approved';

  bool get isInProgress => switch (_status) {
        'created' || 'started' || 'submitted' || 'review' => true,
        _ => false,
      };

  bool get isUnderReview => isInProgress;

  bool get isPending => _status == 'not_started' || _status == 'abandoned';

  bool get isRejected =>
      isDenied ||
      _status == 'declined' ||
      _status == 'resubmission_requested' ||
      _status == 'expired';

  bool get canRetry => isRejected || isPending;

  bool get canStartSession => !isApproved && !isInProgress;

  bool get isPermanentlyBlocked => false;

  bool get canResubmit => canRetry;

  /// Local fallback before GET /verification/status returns.
  factory AccountVerification.fromProfileSnapshot(ProfileSnapshot? profile) {
    if (profile == null) {
      return const AccountVerification(
        isVerified: false,
        passportUrl: '',
        verificationStatus: 'NOT_STARTED',
      );
    }
    if (profile.isVerified) {
      return const AccountVerification(
        isVerified: true,
        passportUrl: '',
        verificationStatus: 'approved',
      );
    }
    final status = profile.verificationStatus ?? 'NOT_STARTED';
    return AccountVerification(
      isVerified: false,
      passportUrl: '',
      verificationStatus: status,
    );
  }

  AccountVerification copyWith({
    bool? isVerified,
    String? passportUrl,
    String? verificationStatus,
    String? rejectionReason,
    int? rejectionCycle,
    String? message,
    String? veriffSessionId,
    String? verificationRequestedAt,
    String? verifiedAt,
    bool? isDenied,
  }) =>
      AccountVerification(
        isVerified: isVerified ?? this.isVerified,
        passportUrl: passportUrl ?? this.passportUrl,
        verificationStatus: verificationStatus ?? this.verificationStatus,
        rejectionReason: rejectionReason ?? this.rejectionReason,
        rejectionCycle: rejectionCycle ?? this.rejectionCycle,
        message: message ?? this.message,
        veriffSessionId: veriffSessionId ?? this.veriffSessionId,
        verificationRequestedAt:
            verificationRequestedAt ?? this.verificationRequestedAt,
        verifiedAt: verifiedAt ?? this.verifiedAt,
        isDenied: isDenied ?? this.isDenied,
      );
}

class ClosedAccountResponse {
  final bool isRemoved;
  final String? message;

  const ClosedAccountResponse({required this.isRemoved, this.message});

  factory ClosedAccountResponse.fromJson(Map<String, dynamic> json) =>
      ClosedAccountResponse(
        isRemoved: json['isRemoved'] as bool? ??
            json['removed'] as bool? ??
            true,
        message: json['message'] as String?,
      );
}

enum VeriffFlowOutcome { canceled, submitted, verified }
