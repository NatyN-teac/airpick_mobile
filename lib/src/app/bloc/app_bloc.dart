import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/storage/token_storage.dart';
import '../../features/onboarding/repository/onboarding_repository.dart';

part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  final IOnboardingRepository _onboardingRepository;
  final TokenStorage _tokenStorage;

  AppBloc(this._onboardingRepository, this._tokenStorage)
      : super(const AppLoading()) {
    on<AppStarted>(_onStarted);
    on<AppOnboardingCompleted>(_onOnboardingCompleted);
    on<AppAuthCompleted>(_onAuthCompleted);
    on<AppLoggedOut>(_onLoggedOut);
  }

  Future<void> _onStarted(
    AppStarted event,
    Emitter<AppState> emit,
  ) async {
    final onboardingDone =
        await _onboardingRepository.isOnboardingCompleted();

    if (!onboardingDone) {
      emit(const ShowOnboarding());
      return;
    }

    final token = await _tokenStorage.getToken();
    emit(token != null ? const ShowHome() : const ShowAuth());
  }

  void _onOnboardingCompleted(
    AppOnboardingCompleted event,
    Emitter<AppState> emit,
  ) {
    emit(const ShowAuth());
  }

  void _onAuthCompleted(
    AppAuthCompleted event,
    Emitter<AppState> emit,
  ) {
    emit(const ShowHome());
  }

  Future<void> _onLoggedOut(
    AppLoggedOut event,
    Emitter<AppState> emit,
  ) async {
    await _tokenStorage.clear();
    emit(const ShowAuth());
  }
}
