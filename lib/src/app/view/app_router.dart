import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/app_bloc.dart';
import '../../core/session/app_session.dart';
import '../../core/theme/app_colors.dart';
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

// Animated splash shown while the app resolves its initial route.
// Performant: one entrance controller (logo) + one repeating shimmer (text).
class _LoadingView extends StatefulWidget {
  const _LoadingView();

  @override
  State<_LoadingView> createState() => _LoadingViewState();
}

class _LoadingViewState extends State<_LoadingView>
    with TickerProviderStateMixin {
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();

  // One short shimmer sweep, played once shortly after the logo appears.
  late final AnimationController _shimmer = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  late final Animation<double> _logoScale = Tween(begin: 0.6, end: 1.0)
      .animate(CurvedAnimation(parent: _entrance, curve: Curves.easeOutBack));
  late final Animation<double> _fade =
      CurvedAnimation(parent: _entrance, curve: Curves.easeOut);

  @override
  void initState() {
    super.initState();
    // Let the logo settle, then sweep the shimmer once.
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) _shimmer.forward();
    });
  }

  @override
  void dispose() {
    _entrance.dispose();
    _shimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : Colors.white;
    // Solid readable colour; the shimmer highlight sweeps over it once.
    final base = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;

    return Scaffold(
      backgroundColor: bg,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo — scale + fade in
            FadeTransition(
              opacity: _fade,
              child: ScaleTransition(
                scale: _logoScale,
                child: Image.asset('assets/logo_me.png', width: 64, height: 64),
              ),
            ),
            const SizedBox(height: 14),
            // "Airpick" — solid text with a single shimmer sweep
            FadeTransition(
              opacity: _fade,
              child: AnimatedBuilder(
                animation: _shimmer,
                builder: (context, _) {
                  final running = _shimmer.value > 0 && _shimmer.value < 1;
                  if (!running) {
                    return Text('Airpick',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.8,
                          color: base,
                        ));
                  }
                  final p = _shimmer.value;
                  return ShaderMask(
                    blendMode: BlendMode.srcIn,
                    shaderCallback: (bounds) => LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [base, AppColors.primary, base],
                      stops: [
                        (p - 0.25).clamp(0.0, 1.0),
                        p.clamp(0.0, 1.0),
                        (p + 0.25).clamp(0.0, 1.0),
                      ],
                    ).createShader(
                        Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                    child: const Text(
                      'Airpick',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.8,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 6),
            FadeTransition(
              opacity: _fade,
              child: Text(
                'Peer-to-peer delivery',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 13,
                  color: isDark
                      ? AppColors.darkTextTertiary
                      : AppColors.textTertiary,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
