import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../app/bloc/app_bloc.dart';
import '../../features/auth/data/firebase_auth_service.dart';
import '../../features/profile/cubit/current_user_cubit.dart';
import '../storage/token_storage.dart';

Future<void> performLogout(BuildContext context) async {
  await FirebaseAuthService().signOut();
  await context.read<TokenStorage>().clear();
  if (!context.mounted) return;
  context.read<CurrentUserCubit>().clear();
  context.read<AppBloc>().add(const AppLoggedOut());
}
