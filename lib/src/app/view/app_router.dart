import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/app_bloc.dart';
import '../../core/session/app_session.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/screens/auth_screen.dart';
import '../../features/home/cubit/user_mode_cubit.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../core/storage/token_storage.dart';
import '../../features/profile/cubit/current_user_cubit.dart';
import '../../features/profile/repository/user_repository.dart';

class AppRouter extends StatefulWidget {
  const AppRouter({super.key});

  @override
  State<AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<AppRouter> {
  StreamSubscription<void>? _unauthorizedSub;

  @override
  void initState() {
    super.initState();
    _unauthorizedSub = AppSession.onUnauthorized.listen((_) {
      if (mounted) {
        context.read<CurrentUserCubit>().clear();
        context.read<AppBloc>().add(const AppLoggedOut());
      }
    });
  }

  @override
  void dispose() {
    _unauthorizedSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthSuccess) {
              context.read<CurrentUserCubit>().setFromUser(state.user);
              context.read<CurrentUserCubit>().refreshFromServer(
                    context.read<UserRepository>(),
                    context.read<TokenStorage>(),
                  );
              final activeMode = state.user.activeMode;
              if (activeMode != null && activeMode.isNotEmpty) {
                context
                    .read<UserModeCubit>()
                    .syncFromServer(UserModeX.fromApi(activeMode));
              }
              context.read<AppBloc>().add(const AppAuthCompleted());
            }
          },
        ),
      ],
      child: BlocBuilder<AppBloc, AppState>(
        builder: (context, state) {
          return switch (state) {
            AppLoading() => const _LoadingView(),
            ShowOnboarding() => const OnboardingScreen(),
            ShowAuth() => const AuthScreen(),
            ShowHome() => const HomeScreen(),
            _ => const SizedBox.shrink(),
          };
        },
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
