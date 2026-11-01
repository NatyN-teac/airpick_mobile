import 'dart:io';

import 'package:flutter/foundation.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/utils/time_format.dart';
import '../models/account_verification.dart';
import 'user_repository.dart';

/// Debug-only demo of the verification flow. Build with
/// `--dart-define=VERIFICATION_DEMO=true` to run the screens against this
/// in-memory fake of the backend contract instead of the real server — so the
/// whole flow can be seen on any account, before the backend is deployed, and
/// on a Simulator. Never active in release builds.
const verificationDemoEnabled =
    kDebugMode && bool.fromEnvironment('VERIFICATION_DEMO');

/// States the demo panel can jump to.
enum DemoVerificationState {
  notStarted,
  underReview,
  approved,
  declinedCooldown,
  declinedRetryNow,
  resubmission,
  locked,
}

class DemoVerificationRepository extends UserRepository {
  DemoVerificationRepository._(super.client);

  static DemoVerificationRepository? _shared;

  /// One instance per app run, so the demo state survives leaving the screen.
  static DemoVerificationRepository shared(ApiClient client) =>
      _shared ??= DemoVerificationRepository._(client);

  static const _latency = Duration(milliseconds: 700);

  Map<String, dynamic> _status = {'status': 'NOT_STARTED'};
  _DemoSession? _session;

  void setState(DemoVerificationState state) {
    _session = null;
    final now = DateTime.now().toUtc();
    _status = switch (state) {
      DemoVerificationState.notStarted => {'status': 'NOT_STARTED'},
      DemoVerificationState.underReview => {
          'status': 'review',
          'sessionId': 'demo',
          'verificationRequestedAt': _iso(now),
        },
      DemoVerificationState.approved => {
          'status': 'approved',
          'isVerified': true,
          'verifiedAt': _iso(now),
        },
      DemoVerificationState.declinedCooldown => {
          'status': 'declined',
          'isDenied': true,
          'reasonCode': 'NAME_MISMATCH',
          'message': 'The name on your document does not match your profile.',
          'canRetryAt': _iso(now.add(const Duration(hours: 24))),
        },
      DemoVerificationState.declinedRetryNow => {
          'status': 'declined',
          'isDenied': true,
          'reasonCode': 'DOCUMENT_EXPIRED',
          'message': 'Your document has expired. Please use a valid document.',
        },
      DemoVerificationState.resubmission => {
          'status': 'resubmission_requested',
          'reasonCode': 'BLURRY',
          'message': 'Your photos were not clear enough. Please retake them '
              'in good light.',
        },
      DemoVerificationState.locked => {
          'status': 'declined',
          'isDenied': true,
          'isLocked': true,
          'reasonCode': 'FACE_MISMATCH',
          'message': 'We could not confirm that the document belongs to you.',
        },
    };
  }

  @override
  Future<VerificationStatusResponse> getVerificationStatus() async {
    await Future<void>.delayed(_latency);
    return VerificationStatusResponse.fromJson({
      'isVerified': false,
      'isDenied': false,
      'isLocked': false,
      ..._status,
    });
  }

  @override
  Future<VerificationSession> createVerificationSession({
    required VerificationDocumentType documentType,
    required String issuingCountry,
  }) async {
    await Future<void>.delayed(_latency);
    final status = _status['status'];
    if (_status['isVerified'] == true) {
      throw const ApiException('Already verified.', errorCode: 'BIZ_008');
    }
    if (_status['isLocked'] == true) {
      throw const ApiException('Locked.', errorCode: 'BIZ_011');
    }
    if (status == 'submitted' || status == 'review') {
      throw const ApiException('In progress.', errorCode: 'BIZ_010');
    }
    final retryAt =
        TimeFormat.parseServerTime(_status['canRetryAt'] as String?);
    if (retryAt != null && retryAt.isAfter(DateTime.now())) {
      throw ApiException(
        'Cooldown.',
        errorCode: 'BIZ_012',
        details: {'canRetryAt': _status['canRetryAt']},
      );
    }

    // An open attempt is returned unchanged, keeping its document type.
    final session = _session ??= _DemoSession(documentType);
    _status = {'status': session.status, 'sessionId': session.id};
    return session.toModel();
  }

  @override
  Future<VerificationSession> uploadVerificationFile({
    required String sessionId,
    required VerificationFileKind kind,
    required File photo,
  }) async {
    await Future<void>.delayed(_latency * 2);
    final session = _session;
    if (session == null || session.id != sessionId) {
      throw const ApiException('Not found.', errorCode: 'DATA_013');
    }
    if (!session.required.contains(kind)) {
      throw const ApiException('Wrong kind.', errorCode: 'UPL_001');
    }
    session.uploaded.add(kind);
    session.status = 'started';
    _status = {'status': 'started', 'sessionId': session.id};
    return session.toModel();
  }

  @override
  Future<VerificationStatusResponse> submitVerification({
    required String sessionId,
    String consentVersion = verificationConsentVersion,
  }) async {
    await Future<void>.delayed(_latency);
    final session = _session;
    if (session == null || session.id != sessionId) {
      throw const ApiException('Not found.', errorCode: 'DATA_013');
    }
    final missing =
        session.required.where((k) => !session.uploaded.contains(k)).toList();
    if (missing.isNotEmpty) {
      throw ApiException(
        'Missing photos.',
        errorCode: 'BIZ_014',
        details: {'missingKinds': missing.map((k) => k.apiValue).toList()},
      );
    }
    _session = null;
    _status = {
      'status': 'submitted',
      'sessionId': session.id,
      'verificationRequestedAt': _iso(DateTime.now().toUtc()),
    };
    return getVerificationStatus();
  }

  static String _iso(DateTime utc) =>
      utc.toIso8601String().replaceFirst(RegExp(r'\.\d+Z$'), '');
}

class _DemoSession {
  final String id = 'demo-${DateTime.now().millisecondsSinceEpoch}';
  final VerificationDocumentType documentType;
  final Set<VerificationFileKind> uploaded = {};
  String status = 'created';

  _DemoSession(this.documentType);

  List<VerificationFileKind> get required => [
        VerificationFileKind.docFront,
        if (documentType != VerificationDocumentType.passport)
          VerificationFileKind.docBack,
        VerificationFileKind.selfieWithDoc,
      ];

  VerificationSession toModel() => VerificationSession(
        sessionId: id,
        status: status,
        expiresAt: DateTime.now().add(const Duration(minutes: 30)),
        documentType: documentType,
        requiredFiles: required,
        uploadedFiles: required.where(uploaded.contains).toList(),
      );
}
