import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:airpick/src/features/onboarding/bloc/onboarding_bloc.dart';
import 'package:airpick/src/features/onboarding/repository/onboarding_repository.dart';

class MockOnboardingRepository extends Mock implements IOnboardingRepository {}

void main() {
  late MockOnboardingRepository repository;

  setUp(() {
    repository = MockOnboardingRepository();
  });

  group('OnboardingBloc', () {
    blocTest<OnboardingBloc, OnboardingState>(
      'emits OnboardingInProgress(page 0) when OnboardingStarted is added',
      build: () => OnboardingBloc(repository),
      act: (bloc) => bloc.add(const OnboardingStarted()),
      expect: () => [
        const OnboardingInProgress(currentPage: 0, totalPages: 3),
      ],
    );

    blocTest<OnboardingBloc, OnboardingState>(
      'emits OnboardingInProgress with updated page when OnboardingPageChanged is added',
      build: () => OnboardingBloc(repository),
      seed: () => const OnboardingInProgress(currentPage: 0, totalPages: 3),
      act: (bloc) => bloc.add(const OnboardingPageChanged(1)),
      expect: () => [
        const OnboardingInProgress(currentPage: 1, totalPages: 3),
      ],
    );

    blocTest<OnboardingBloc, OnboardingState>(
      'emits OnboardingDone and saves flag when OnboardingCompleted is added',
      setUp: () => when(() => repository.completeOnboarding())
          .thenAnswer((_) async {}),
      build: () => OnboardingBloc(repository),
      act: (bloc) => bloc.add(const OnboardingCompleted()),
      expect: () => [const OnboardingDone()],
      verify: (_) => verify(() => repository.completeOnboarding()).called(1),
    );
  });
}
