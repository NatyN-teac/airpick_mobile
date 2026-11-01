import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:guzomy/src/core/network/api_exception.dart';
import 'package:guzomy/src/features/countries/models/iso3_country_codes.dart';
import 'package:guzomy/src/features/profile/cubit/account_verification_cubit.dart';
import 'package:guzomy/src/features/profile/cubit/current_user_cubit.dart';
import 'package:guzomy/src/features/profile/models/account_verification.dart';
import 'package:guzomy/src/features/profile/repository/user_repository.dart';
import 'package:guzomy/src/features/settings/repository/settings_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockUserRepository extends Mock implements UserRepository {}

const _sessionJson = {
  'sessionId': 's-1',
  'status': 'created',
  'expiresAt': '2026-10-30T10:30:00',
  'documentType': 'PASSPORT',
  'requiredFiles': ['DOC_FRONT', 'SELFIE_WITH_DOC'],
  'uploadedFiles': <String>[],
};

VerificationStatusResponse _status(Map<String, dynamic> overrides) =>
    VerificationStatusResponse.fromJson({
      'status': 'NOT_STARTED',
      'isVerified': false,
      'isDenied': false,
      'isLocked': false,
      ...overrides,
    });

void main() {
  setUpAll(() {
    registerFallbackValue(VerificationDocumentType.passport);
    registerFallbackValue(VerificationFileKind.docFront);
    registerFallbackValue(File('x'));
  });

  group('models', () {
    test('session reports the photos still missing', () {
      final session = VerificationSession.fromJson({
        ..._sessionJson,
        'uploadedFiles': ['DOC_FRONT'],
      });

      expect(session.documentType, VerificationDocumentType.passport);
      expect(session.missingFiles, [VerificationFileKind.selfieWithDoc]);
      expect(session.isComplete, isFalse);
    });

    test('timestamps without a zone are read as UTC', () {
      final s = _status({'canRetryAt': '2026-10-31T10:12:00'});

      expect(s.canRetryAt!.toUtc(), DateTime.utc(2026, 10, 31, 10, 12));
    });

    test('a running cooldown blocks a new attempt', () {
      final v = _status({
        'status': 'declined',
        'isDenied': true,
        'canRetryAt': DateTime.now()
            .toUtc()
            .add(const Duration(hours: 1))
            .toIso8601String(),
      }).toAccountVerification();

      expect(v.isCoolingDown(), isTrue);
      expect(v.canStartSession, isFalse);
    });

    test('locked and under-review attempts cannot start', () {
      expect(
        _status({'status': 'declined', 'isLocked': true})
            .toAccountVerification()
            .canStartSession,
        isFalse,
      );
      expect(
        _status({'status': 'review'}).toAccountVerification().canStartSession,
        isFalse,
      );
      expect(
        _status({'status': 'expired'}).toAccountVerification().canStartSession,
        isTrue,
      );
    });

    test('alpha-2 country codes convert to alpha-3', () {
      expect(iso3CountryCode('ET'), 'ETH');
      expect(iso3CountryCode('us'), 'USA');
      expect(iso3CountryCode('ZZ'), isNull);
    });
  });

  group('AccountVerificationCubit', () {
    late _MockUserRepository users;
    late CurrentUserCubit profile;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      profile = CurrentUserCubit(SettingsRepository(prefs));
      users = _MockUserRepository();
      when(() => users.getVerificationStatus())
          .thenAnswer((_) async => _status({}));
    });

    AccountVerificationCubit build() => AccountVerificationCubit(users, profile);

    test('startSession sends the document type and country', () async {
      when(() => users.createVerificationSession(
            documentType: any(named: 'documentType'),
            issuingCountry: any(named: 'issuingCountry'),
          )).thenAnswer((_) async => VerificationSession.fromJson(_sessionJson));
      final cubit = build();

      final ok = await cubit.startSession(
        documentType: VerificationDocumentType.passport,
        issuingCountry: 'ETH',
      );

      expect(ok, isTrue);
      expect(cubit.state.session?.sessionId, 's-1');
      expect(cubit.state.resumedDocumentType, isNull);
      verify(() => users.createVerificationSession(
            documentType: VerificationDocumentType.passport,
            issuingCountry: 'ETH',
          )).called(1);
      await cubit.close();
    });

    test('flags a resumed attempt with a different document type', () async {
      when(() => users.createVerificationSession(
            documentType: any(named: 'documentType'),
            issuingCountry: any(named: 'issuingCountry'),
          )).thenAnswer((_) async => VerificationSession.fromJson(_sessionJson));
      final cubit = build();

      await cubit.startSession(
        documentType: VerificationDocumentType.nationalId,
        issuingCountry: 'ETH',
      );

      expect(cubit.state.resumedDocumentType, VerificationDocumentType.passport);
      await cubit.close();
    });

    test('cooldown error stores canRetryAt and reports the issue', () async {
      when(() => users.createVerificationSession(
            documentType: any(named: 'documentType'),
            issuingCountry: any(named: 'issuingCountry'),
          )).thenThrow(const ApiException(
        'Cooldown',
        statusCode: 429,
        errorCode: 'BIZ_012',
        details: {'canRetryAt': '2099-01-01T00:00:00'},
      ));
      final cubit = build();
      await cubit.load();

      final ok = await cubit.startSession(
        documentType: VerificationDocumentType.passport,
        issuingCountry: 'ETH',
      );

      expect(ok, isFalse);
      expect(cubit.state.issue, VerificationIssue.cooldown);
      expect(
        cubit.state.verification?.canRetryAt?.toUtc(),
        DateTime.utc(2099),
      );
      await cubit.close();
    });

    test('old-app error asks for an update', () async {
      when(() => users.createVerificationSession(
            documentType: any(named: 'documentType'),
            issuingCountry: any(named: 'issuingCountry'),
          )).thenThrow(const ApiException('Update', errorCode: 'BIZ_018'));
      final cubit = build();

      await cubit.startSession(
        documentType: VerificationDocumentType.passport,
        issuingCountry: 'ETH',
      );

      expect(cubit.state.issue, VerificationIssue.appUpdateRequired);
      await cubit.close();
    });

    test('an expired session is dropped so capture restarts', () async {
      when(() => users.createVerificationSession(
            documentType: any(named: 'documentType'),
            issuingCountry: any(named: 'issuingCountry'),
          )).thenAnswer((_) async => VerificationSession.fromJson(_sessionJson));
      when(() => users.uploadVerificationFile(
            sessionId: any(named: 'sessionId'),
            kind: any(named: 'kind'),
            photo: any(named: 'photo'),
          )).thenThrow(const ApiException('Expired', errorCode: 'BIZ_013'));
      final dir = await Directory.systemTemp.createTemp('verif');
      final photo = File('${dir.path}/front.jpg')..writeAsBytesSync([1, 2, 3]);
      final cubit = build();
      await cubit.startSession(
        documentType: VerificationDocumentType.passport,
        issuingCountry: 'ETH',
      );

      final ok = await cubit.uploadPhoto(VerificationFileKind.docFront, photo);

      expect(ok, isFalse);
      expect(cubit.state.session, isNull);
      expect(cubit.state.issue, VerificationIssue.sessionExpired);
      await cubit.close();
      await dir.delete(recursive: true);
    });

    test('submit clears the session and applies the new status', () async {
      when(() => users.createVerificationSession(
            documentType: any(named: 'documentType'),
            issuingCountry: any(named: 'issuingCountry'),
          )).thenAnswer((_) async => VerificationSession.fromJson({
            ..._sessionJson,
            'status': 'started',
            'uploadedFiles': ['DOC_FRONT', 'SELFIE_WITH_DOC'],
          }));
      when(() => users.submitVerification(sessionId: 's-1'))
          .thenAnswer((_) async => _status({'status': 'submitted'}));
      final cubit = build();
      await cubit.startSession(
        documentType: VerificationDocumentType.passport,
        issuingCountry: 'ETH',
      );

      final ok = await cubit.submit();

      expect(ok, isTrue);
      expect(cubit.state.session, isNull);
      expect(cubit.state.verification?.isUnderReview, isTrue);
      await cubit.close();
    });

    test('missing-files error marks those photos as not uploaded', () async {
      when(() => users.createVerificationSession(
            documentType: any(named: 'documentType'),
            issuingCountry: any(named: 'issuingCountry'),
          )).thenAnswer((_) async => VerificationSession.fromJson({
            ..._sessionJson,
            'uploadedFiles': ['DOC_FRONT', 'SELFIE_WITH_DOC'],
          }));
      when(() => users.submitVerification(sessionId: 's-1')).thenThrow(
        const ApiException(
          'Missing',
          errorCode: 'BIZ_014',
          details: {
            'missingKinds': ['SELFIE_WITH_DOC'],
          },
        ),
      );
      final cubit = build();
      await cubit.startSession(
        documentType: VerificationDocumentType.passport,
        issuingCountry: 'ETH',
      );

      await cubit.submit();

      expect(cubit.state.issue, VerificationIssue.filesMissing);
      expect(
        cubit.state.session?.missingFiles,
        [VerificationFileKind.selfieWithDoc],
      );
      await cubit.close();
    });
  });
}
