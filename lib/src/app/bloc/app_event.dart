part of 'app_bloc.dart';

abstract class AppEvent extends Equatable {
  const AppEvent();

  @override
  List<Object?> get props => [];
}

class AppStarted extends AppEvent {
  const AppStarted();
}

class AppOnboardingCompleted extends AppEvent {
  const AppOnboardingCompleted();
}

class AppAuthCompleted extends AppEvent {
  const AppAuthCompleted();
}

class AppLoggedOut extends AppEvent {
  const AppLoggedOut();
}
