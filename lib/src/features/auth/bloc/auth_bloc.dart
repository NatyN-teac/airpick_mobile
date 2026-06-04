import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../exceptions/auth_exceptions.dart';
import '../models/user_model.dart';
import '../repository/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final IAuthRepository _repository;

  AuthBloc(this._repository) : super(const AuthInitial()) {
    on<AuthGoogleSignInRequested>(_onGoogleSignIn);
    on<AuthAppleSignInRequested>(_onAppleSignIn);
  }

  Future<void> _onGoogleSignIn(
    AuthGoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) =>
      _signIn(() => _repository.signInWithGoogle(), emit);

  Future<void> _onAppleSignIn(
    AuthAppleSignInRequested event,
    Emitter<AuthState> emit,
  ) =>
      _signIn(() => _repository.signInWithApple(), emit);

  Future<void> _signIn(
    Future<UserModel> Function() call,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await call();
      emit(AuthSuccess(user));
    } on AuthCancelledException catch (e) {
      emit(AuthCancelled(e.providerName));
    } on AuthConfigurationException catch (e) {
      emit(AuthFailure(e.message));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }
}
