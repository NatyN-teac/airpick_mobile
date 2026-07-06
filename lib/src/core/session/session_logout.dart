import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../app/bloc/app_bloc.dart';
import '../../features/profile/cubit/current_user_cubit.dart';
import '../notifications/device_registration_service.dart';
import 'app_session.dart';
import '../storage/token_storage.dart';

Future<void> performLogout(BuildContext context) async {
  final storage = context.read<TokenStorage>();
  // Unregister the FCM token first — the DELETE needs the still-valid JWT.
  await context.read<DeviceRegistrationService>().unregisterBeforeLogout();
  await AppSession.expireSession(storage);
  if (!context.mounted) return;
  context.read<CurrentUserCubit>().clear();
  context.read<AppBloc>().add(const AppLoggedOut());
}
