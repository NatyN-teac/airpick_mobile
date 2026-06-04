part of 'app_bloc.dart';

abstract class AppState extends Equatable {
  const AppState();

  @override
  List<Object?> get props => [];
}

class AppLoading extends AppState {
  const AppLoading();
}

class ShowOnboarding extends AppState {
  const ShowOnboarding();
}

class ShowAuth extends AppState {
  const ShowAuth();
}

class ShowHome extends AppState {
  const ShowHome();
}
