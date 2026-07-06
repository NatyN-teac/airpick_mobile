part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthSuccess extends AuthState {
  final UserModel user;
  const AuthSuccess(this.user);

  @override
  List<Object?> get props => [user.id];
}

class AuthFailure extends AuthState {
  final String message;

  /// The provider that was being used when the failure occurred, so the UI can
  /// retry the correct one instead of guessing from the error message.
  final String providerName;

  const AuthFailure(this.message, {this.providerName = 'Google'});

  @override
  List<Object?> get props => [message, providerName];
}

class AuthCancelled extends AuthState {
  final String providerName;
  const AuthCancelled(this.providerName);

  @override
  List<Object?> get props => [providerName];
}
