import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/onboarding_repository.dart';

part 'onboarding_event.dart';
part 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final IOnboardingRepository _repository;
  static const int _totalPages = 3;

  OnboardingBloc(this._repository) : super(const OnboardingInitial()) {
    on<OnboardingStarted>(_onStarted);
    on<OnboardingPageChanged>(_onPageChanged);
    on<OnboardingCompleted>(_onCompleted);
  }

  void _onStarted(OnboardingStarted event, Emitter<OnboardingState> emit) {
    emit(const OnboardingInProgress(currentPage: 0, totalPages: _totalPages));
  }

  void _onPageChanged(
    OnboardingPageChanged event,
    Emitter<OnboardingState> emit,
  ) {
    emit(
      OnboardingInProgress(
        currentPage: event.page,
        totalPages: _totalPages,
      ),
    );
  }

  Future<void> _onCompleted(
    OnboardingCompleted event,
    Emitter<OnboardingState> emit,
  ) async {
    await _repository.completeOnboarding();
    emit(const OnboardingDone());
  }
}
