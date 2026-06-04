part of 'onboarding_bloc.dart';

abstract class OnboardingState extends Equatable {
  const OnboardingState();

  @override
  List<Object?> get props => [];
}

class OnboardingInitial extends OnboardingState {
  const OnboardingInitial();
}

class OnboardingInProgress extends OnboardingState {
  final int currentPage;
  final int totalPages;

  const OnboardingInProgress({
    required this.currentPage,
    required this.totalPages,
  });

  @override
  List<Object?> get props => [currentPage, totalPages];
}

class OnboardingDone extends OnboardingState {
  const OnboardingDone();
}
