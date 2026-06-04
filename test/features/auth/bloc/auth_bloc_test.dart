import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:airpick/src/features/auth/bloc/auth_bloc.dart';
import 'package:airpick/src/features/auth/models/user_model.dart';
import 'package:airpick/src/features/auth/repository/auth_repository.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

final _fakeUser = UserModel(
  id: '1',
  email: 'test@test.com',
  providerId: 'uid',
  role: 'CUSTOMER',
  isActiveUser: true,
  isBlocked: false,
  createdAt: '2026-01-01',
  token: 'jwt',
  profile: UserProfile(
    id: 'p1',
    isVerified: false,
    createdAt: '2026-01-01',
    updatedAt: '2026-01-01',
  ),
);

void main() {
  late MockAuthRepository repository;

  setUp(() {
    repository = MockAuthRepository();
  });

  group('AuthBloc — Google', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthSuccess] on successful Google sign-in',
      setUp: () => when(() => repository.signInWithGoogle())
          .thenAnswer((_) async => _fakeUser),
      build: () => AuthBloc(repository),
      act: (bloc) => bloc.add(const AuthGoogleSignInRequested()),
      expect: () => [const AuthLoading(), AuthSuccess(_fakeUser)],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthFailure] when Google sign-in throws',
      setUp: () => when(() => repository.signInWithGoogle())
          .thenThrow(Exception('network error')),
      build: () => AuthBloc(repository),
      act: (bloc) => bloc.add(const AuthGoogleSignInRequested()),
      expect: () => [const AuthLoading(), isA<AuthFailure>()],
    );
  });

  group('AuthBloc — Apple', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthSuccess] on successful Apple sign-in',
      setUp: () => when(() => repository.signInWithApple())
          .thenAnswer((_) async => _fakeUser),
      build: () => AuthBloc(repository),
      act: (bloc) => bloc.add(const AuthAppleSignInRequested()),
      expect: () => [const AuthLoading(), AuthSuccess(_fakeUser)],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthFailure] when Apple sign-in throws',
      setUp: () => when(() => repository.signInWithApple())
          .thenThrow(Exception('cancelled')),
      build: () => AuthBloc(repository),
      act: (bloc) => bloc.add(const AuthAppleSignInRequested()),
      expect: () => [const AuthLoading(), isA<AuthFailure>()],
    );
  });
}
