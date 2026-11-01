import '../../../core/utils/time_format.dart';
import 'profile_snapshot.dart';

/// Identity document the user verifies with (`documentType` on the wire).
enum VerificationDocumentType {
  passport('PASSPORT'),
  nationalId('NATIONAL_ID'),
  driverLicense('DRIVER_LICENSE'),
  residencePermit('RESIDENCE_PERMIT');

  final String apiValue;
  const VerificationDocumentType(this.apiValue);

  static VerificationDocumentType? fromApi(String? value) {
    for (final t in values) {
      if (t.apiValue == value) return t;
    }
    return null;
  }
}

/// One photo the backend asks for (`kind` on the wire).
enum VerificationFileKind {
  docFront('DOC_FRONT'),
  docBack('DOC_BACK'),
  selfieWithDoc('SELFIE_WITH_DOC');

  final String apiValue;
  const VerificationFileKind(this.apiValue);

  static VerificationFileKind? fromApi(String? value) {
    for (final k in values) {
      if (k.apiValue == value) return k;
    }
    return null;
  }
}

/// Version of the consent text shown before submitting.
const verificationConsentVersion = 'v1';

List<VerificationFileKind> _kinds(Object? raw) => raw is List
    ? raw
        .map((e) => VerificationFileKind.fromApi(e?.toString()))
        .whereType<VerificationFileKind>()
        .toList()
    : const [];

/// POST /users/verification/session and POST .../files response.
class VerificationSession {
  final String sessionId;
  final String status;
  final DateTime? expiresAt;
  final VerificationDocumentType? documentType;

  /// Photos the server needs for [documentType]. Drives the capture screens.
  final List<VerificationFileKind> requiredFiles;

  /// Photos the server already has for this attempt.
  final List<VerificationFileKind> uploadedFiles;

  const VerificationSession({
    required this.sessionId,
    required this.status,
    this.expiresAt,
    this.documentType,
    this.requiredFiles = const [],
    this.uploadedFiles = const [],
  });

  factory VerificationSession.fromJson(Map<String, dynamic> json) =>
      VerificationSession(
        sessionId: json['sessionId'] as String? ?? '',
        status: json['status'] as String? ?? 'created',
        expiresAt: TimeFormat.parseServerTime(json['expiresAt'] as String?),
        documentType:
            VerificationDocumentType.fromApi(json['documentType'] as String?),
        requiredFiles: _kinds(json['requiredFiles']),
        uploadedFiles: _kinds(json['uploadedFiles']),
      );

  List<VerificationFileKind> get missingFiles =>
      requiredFiles.where((k) => !uploadedFiles.contains(k)).toList();

  bool get isComplete => requiredFiles.isNotEmpty && missingFiles.isEmpty;
}

/// GET /users/verification/status (also returned by POST .../submit).
class VerificationStatusResponse {
  final String status;
  final bool isVerified;
  final bool isDenied;
  final bool isLocked;
  final String? reasonCode;
  final String? message;
  final String? sessionId;
  final String? verificationRequestedAt;
  final String? verifiedAt;
  final DateTime? canRetryAt;

  const VerificationStatusResponse({
    required this.status,
    required this.isVerified,
    required this.isDenied,
    this.isLocked = false,
    this.reasonCode,
    this.message,
    this.sessionId,
    this.verificationRequestedAt,
    this.verifiedAt,
    this.canRetryAt,
  });

  factory VerificationStatusResponse.fromJson(Map<String, dynamic> json) =>
      VerificationStatusResponse(
        status: json['status'] as String? ?? 'NOT_STARTED',
        isVerified: json['isVerified'] as bool? ?? false,
        isDenied: json['isDenied'] as bool? ?? false,
        isLocked: json['isLocked'] as bool? ?? false,
        reasonCode: json['reasonCode'] as String?,
        message: json['message'] as String?,
        sessionId: json['sessionId'] as String?,
        verificationRequestedAt: json['verificationRequestedAt'] as String?,
        verifiedAt: json['verifiedAt'] as String?,
        canRetryAt: TimeFormat.parseServerTime(json['canRetryAt'] as String?),
      );

  AccountVerification toAccountVerification() => AccountVerification(
        isVerified: isVerified,
        verificationStatus: status,
        isDenied: isDenied,
        isLocked: isLocked,
        reasonCode: reasonCode,
        message: message,
        sessionId: sessionId,
        verificationRequestedAt: verificationRequestedAt,
        verifiedAt: verifiedAt,
        canRetryAt: canRetryAt,
      );
}

class AccountVerification {
  final bool isVerified;
  final String verificationStatus;
  final bool isDenied;

  /// Locked after too many declines (or blocked) — only support can help.
  final bool isLocked;

  /// Fixed backend code for a decline / resubmission request.
  final String? reasonCode;

  /// Server's pre-written, user-safe text for [reasonCode].
  final String? message;
  final String? sessionId;
  final String? verificationRequestedAt;
  final String? verifiedAt;

  /// Earliest time a new attempt may start after a cooldown decline.
  final DateTime? canRetryAt;

  const AccountVerification({
    required this.isVerified,
    required this.verificationStatus,
    this.isDenied = false,
    this.isLocked = false,
    this.reasonCode,
    this.message,
    this.sessionId,
    this.verificationRequestedAt,
    this.verifiedAt,
    this.canRetryAt,
  });

  String get _status => verificationStatus.toLowerCase();

  bool get isApproved => isVerified || _status == 'approved';

  /// Attempt open on the server but not submitted yet — resume capture.
  bool get isCapturing => _status == 'created' || _status == 'started';

  /// Submitted and waiting for (or with) a reviewer.
  bool get isUnderReview => _status == 'submitted' || _status == 'review';

  bool get isResubmissionRequested => _status == 'resubmission_requested';

  bool get isDeclined => isDenied || _status == 'declined';

  bool get isRejected => isDeclined || isResubmissionRequested;

  bool isCoolingDown([DateTime? now]) =>
      canRetryAt != null && canRetryAt!.isAfter(now ?? DateTime.now());

  /// Whether a new or resumed attempt may start right now.
  bool get canStartSession =>
      !isApproved && !isUnderReview && !isLocked && !isCoolingDown();

  AccountVerification copyWith({String? verificationStatus, DateTime? canRetryAt}) =>
      AccountVerification(
        isVerified: isVerified,
        verificationStatus: verificationStatus ?? this.verificationStatus,
        isDenied: isDenied,
        isLocked: isLocked,
        reasonCode: reasonCode,
        message: message,
        sessionId: sessionId,
        verificationRequestedAt: verificationRequestedAt,
        verifiedAt: verifiedAt,
        canRetryAt: canRetryAt ?? this.canRetryAt,
      );

  /// Local fallback before GET /verification/status returns.
  factory AccountVerification.fromProfileSnapshot(ProfileSnapshot? profile) {
    if (profile == null) {
      return const AccountVerification(
        isVerified: false,
        verificationStatus: 'NOT_STARTED',
      );
    }
    if (profile.isVerified) {
      return const AccountVerification(
        isVerified: true,
        verificationStatus: 'approved',
      );
    }
    return AccountVerification(
      isVerified: false,
      verificationStatus: profile.verificationStatus ?? 'NOT_STARTED',
    );
  }
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
