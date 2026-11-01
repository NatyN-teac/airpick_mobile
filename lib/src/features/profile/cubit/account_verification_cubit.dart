import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/utils/app_refresh_bus.dart';
import '../../../core/utils/time_format.dart';
import '../cubit/current_user_cubit.dart';
import '../models/account_verification.dart';
import '../repository/user_repository.dart';

part 'account_verification_state.dart';

/// Backend accepts photos up to 10 MB.
const _maxPhotoBytes = 10 * 1024 * 1024;

/// Drives the in-house verification flow: pick a document, upload each photo
/// the server asks for, submit, then follow the status as a reviewer decides.
class AccountVerificationCubit extends Cubit<AccountVerificationState> {
  final UserRepository _users;
  final CurrentUserCubit _profile;

  /// False in the debug demo so fake statuses don't overwrite the real
  /// profile's verified flag.
  final bool _syncProfile;
  StreamSubscription<void>? _pushSub;

  AccountVerificationCubit(
    this._users,
    this._profile, {
    bool syncProfile = true,
  })  : _syncProfile = syncProfile,
        super(const AccountVerificationState()) {
    // A verification push (approved / declined / resubmission) arrived.
    _pushSub = AppRefreshBus.instance
        .on(RefreshTopic.verification)
        .listen((_) => refresh());
  }

  /// Local snapshot first, then GET /users/verification/status.
  Future<void> load() async {
    final local = AccountVerification.fromProfileSnapshot(_profile.state);
    emit(state.copyWith(
      status: AccountVerificationStatus.loaded,
      verification: local,
      clearError: true,
    ));
    await refresh();
  }

  Future<void> refresh() async {
    try {
      final response = await _users.getVerificationStatus();
      if (isClosed) return;
      _applyVerification(response.toAccountVerification());
    } catch (e, st) {
      appLogger.e('[AccountVerificationCubit] status refresh failed', e, st);
      if (!isClosed && state.verification == null) {
        emit(state.copyWith(
          status: AccountVerificationStatus.loaded,
          verification: AccountVerification.fromProfileSnapshot(_profile.state),
        ));
      }
    }
  }

  /// POST /session. Returns true when an attempt is ready for capture. If the
  /// user already had an open attempt the server returns it unchanged, with
  /// its original document type.
  Future<bool> startSession({
    required VerificationDocumentType documentType,
    required String issuingCountry,
  }) async {
    emit(state.copyWith(action: VerificationAction.starting));
    try {
      final session = await _users.createVerificationSession(
        documentType: documentType,
        issuingCountry: issuingCountry,
      );
      if (isClosed) return false;
      final resumedOther =
          session.documentType != null && session.documentType != documentType;
      emit(state.copyWith(
        action: VerificationAction.none,
        session: session,
        resumedDocumentType: resumedOther ? session.documentType : null,
        clearResumedDocumentType: !resumedOther,
        verification: state.verification
            ?.copyWith(verificationStatus: session.status),
      ));
      return true;
    } on ApiException catch (e) {
      appLogger.e('[AccountVerificationCubit] startSession failed', e);
      await _onStartError(e);
      return false;
    } catch (e, st) {
      appLogger.e('[AccountVerificationCubit] startSession failed', e, st);
      _emitGeneric(e);
      return false;
    }
  }

  Future<void> _onStartError(ApiException e) async {
    switch (e.errorCode) {
      case 'BIZ_018':
        _emitIssue(VerificationIssue.appUpdateRequired, e.message);
      case 'BIZ_008':
        // Already verified — the refreshed status shows the verified state.
        emit(state.copyWith(action: VerificationAction.none));
        await refresh();
      case 'BIZ_011':
        await refresh();
        _emitIssue(VerificationIssue.locked, e.message);
      case 'BIZ_010':
        await refresh();
        _emitIssue(VerificationIssue.alreadyInProgress, e.message);
      case 'BIZ_012':
        final retryAt =
            TimeFormat.parseServerTime(e.details?['canRetryAt']?.toString());
        await refresh();
        if (isClosed) return;
        if (retryAt != null) {
          emit(state.copyWith(
            verification: state.verification?.copyWith(canRetryAt: retryAt),
          ));
        }
        _emitIssue(VerificationIssue.cooldown, e.message);
      default:
        _emitGeneric(e);
    }
  }

  /// POST /session/{id}/files for one [kind]. Retakes replace the old photo.
  Future<bool> uploadPhoto(VerificationFileKind kind, File photo) async {
    final session = state.session;
    if (session == null) return false;

    if (await photo.length() > _maxPhotoBytes) {
      _emitIssue(VerificationIssue.invalidFile, null);
      return false;
    }

    emit(state.copyWith(
      action: VerificationAction.uploading,
      uploadingKind: kind,
    ));
    try {
      final updated = await _users.uploadVerificationFile(
        sessionId: session.sessionId,
        kind: kind,
        photo: photo,
      );
      if (isClosed) return false;
      emit(state.copyWith(
        action: VerificationAction.none,
        session: updated,
        verification: state.verification
            ?.copyWith(verificationStatus: updated.status),
      ));
      return true;
    } on ApiException catch (e) {
      appLogger.e('[AccountVerificationCubit] uploadPhoto failed', e);
      switch (e.errorCode) {
        case 'BIZ_013' || 'DATA_013':
          await _onSessionGone();
        case 'UPL_001':
          _emitIssue(VerificationIssue.invalidFile, e.message);
        default:
          _emitGeneric(e);
      }
      return false;
    } catch (e, st) {
      appLogger.e('[AccountVerificationCubit] uploadPhoto failed', e, st);
      _emitGeneric(e);
      return false;
    }
  }

  /// POST /session/{id}/submit with the consent version the user accepted.
  Future<bool> submit() async {
    final session = state.session;
    if (session == null) return false;

    emit(state.copyWith(action: VerificationAction.submitting));
    try {
      final response = await _users.submitVerification(
        sessionId: session.sessionId,
      );
      if (isClosed) return false;
      emit(state.copyWith(clearSession: true));
      _applyVerification(response.toAccountVerification());
      return true;
    } on ApiException catch (e) {
      appLogger.e('[AccountVerificationCubit] submit failed', e);
      switch (e.errorCode) {
        case 'BIZ_014':
          final raw = e.details?['missingKinds'];
          final missing = raw is List
              ? raw
                  .map((k) => VerificationFileKind.fromApi(k?.toString()))
                  .whereType<VerificationFileKind>()
                  .toSet()
              : <VerificationFileKind>{};
          emit(state.copyWith(
            session: VerificationSession(
              sessionId: session.sessionId,
              status: session.status,
              expiresAt: session.expiresAt,
              documentType: session.documentType,
              requiredFiles: session.requiredFiles,
              uploadedFiles: session.requiredFiles
                  .where((k) => !missing.contains(k))
                  .toList(),
            ),
          ));
          _emitIssue(VerificationIssue.filesMissing, e.message);
        case 'BIZ_013' || 'DATA_013':
          await _onSessionGone();
        default:
          _emitGeneric(e);
      }
      return false;
    } catch (e, st) {
      appLogger.e('[AccountVerificationCubit] submit failed', e, st);
      _emitGeneric(e);
      return false;
    }
  }

  /// The 30-minute window lapsed (or the attempt was cleared): drop it so the
  /// user starts again from the document picker.
  Future<void> _onSessionGone() async {
    emit(state.copyWith(clearSession: true));
    await refresh();
    _emitIssue(VerificationIssue.sessionExpired, null);
  }

  void _emitIssue(VerificationIssue issue, String? message) {
    if (isClosed) return;
    emit(state.withIssue(issue, message: message));
  }

  void _emitGeneric(Object e) => _emitIssue(
        VerificationIssue.generic,
        e.toString().replaceFirst('Exception: ', ''),
      );

  void _applyVerification(AccountVerification verification) {
    if (_syncProfile) {
      _profile.updateVerification(
        isVerified: verification.isApproved,
        status: verification.verificationStatus,
      );
    }
    emit(state.copyWith(
      status: AccountVerificationStatus.loaded,
      verification: verification,
      clearError: true,
    ));
  }

  @override
  Future<void> close() {
    _pushSub?.cancel();
    return super.close();
  }
}
