class AccountVerification {
  final bool isVerified;
  final String passportUrl;
  final String verificationStatus;
  final String? rejectionReason;
  final int? rejectionCycle;

  const AccountVerification({
    required this.isVerified,
    required this.passportUrl,
    required this.verificationStatus,
    this.rejectionReason,
    this.rejectionCycle,
  });

  factory AccountVerification.fromJson(Map<String, dynamic> json) =>
      AccountVerification(
        isVerified: json['isVerified'] as bool? ??
            json['verified'] as bool? ??
            false,
        passportUrl: json['passportUrl'] as String? ?? '',
        verificationStatus:
            json['verificationStatus'] as String? ?? 'PENDING',
        rejectionReason: json['rejectionReason'] as String?,
        rejectionCycle: json['rejectionCycle'] as int?,
      );

  bool get isPending => verificationStatus == 'PENDING';
  bool get isUnderReview => verificationStatus == 'UNDER_REVIEW';
  bool get isApproved => verificationStatus == 'APPROVED' || isVerified;
  bool get isRejected => verificationStatus == 'REJECTED';

  bool get canResubmit {
    if (!isRejected) return true;
    if (rejectionCycle == null) return true;
    return rejectionCycle! <= 3;
  }

  bool get isPermanentlyBlocked {
    if (!isRejected) return false;
    if (rejectionCycle == null) return false;
    return rejectionCycle! > 3;
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
