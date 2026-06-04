import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:airpick/src/app/bloc/app_bloc.dart';
import 'package:airpick/src/core/storage/token_storage.dart';
import 'package:airpick/src/features/onboarding/repository/onboarding_repository.dart';

class MockOnboardingRepository extends Mock implements IOnboardingRepository {}
class MockTokenStorage extends Mock implements TokenStorage {}

void main() {
  late MockOnboardingRepository repository;
  late MockTokenStorage tokenStorage;

  setUp(() {
    repository = MockOnboardingRepository();
    tokenStorage = MockTokenStorage();
  });

  AppBloc buildBloc() => AppBloc(repository, tokenStorage);

  group('AppBloc', () {
    blocTest<AppBloc, AppState>(
      'emits ShowOnboarding when onboarding not completed',
      setUp: () => when(() => repository.isOnboardingCompleted())
          .thenAnswer((_) async => false),
      build: buildBloc,
      act: (bloc) => bloc.add(const AppStarted()),
      expect: () => [const ShowOnboarding()],
    );

    blocTest<AppBloc, AppState>(
      'emits ShowAuth when onboarding done but no saved token',
      setUp: () {
        when(() => repository.isOnboardingCompleted())
            .thenAnswer((_) async => true);
        when(() => tokenStorage.getToken()).thenAnswer((_) async => null);
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const AppStarted()),
      expect: () => [const ShowAuth()],
    );

    blocTest<AppBloc, AppState>(
      'emits ShowHome when onboarding done and token exists',
      setUp: () {
        when(() => repository.isOnboardingCompleted())
            .thenAnswer((_) async => true);
        when(() => tokenStorage.getToken())
            .thenAnswer((_) async => 'saved.jwt.token');
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const AppStarted()),
      expect: () => [const ShowHome()],
    );

    blocTest<AppBloc, AppState>(
      'emits ShowAuth when AppOnboardingCompleted is added',
      build: buildBloc,
      seed: () => const ShowOnboarding(),
      act: (bloc) => bloc.add(const AppOnboardingCompleted()),
      expect: () => [const ShowAuth()],
    );

    blocTest<AppBloc, AppState>(
      'emits ShowHome when AppAuthCompleted is added',
      build: buildBloc,
      seed: () => const ShowAuth(),
      act: (bloc) => bloc.add(const AppAuthCompleted()),
      expect: () => [const ShowHome()],
    );

    blocTest<AppBloc, AppState>(
      'emits ShowAuth and clears token when AppLoggedOut is added',
      setUp: () =>
          when(() => tokenStorage.clear()).thenAnswer((_) async {}),
      build: buildBloc,
      seed: () => const ShowHome(),
      act: (bloc) => bloc.add(const AppLoggedOut()),
      expect: () => [const ShowAuth()],
      verify: (_) => verify(() => tokenStorage.clear()).called(1),
    );
  });
}
