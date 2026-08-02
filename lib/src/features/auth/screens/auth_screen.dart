import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show Platform;
import '../bloc/auth_bloc.dart';
import '../widgets/social_sign_in_button.dart';
import '../widgets/cancelled_sheet.dart' show CancelledDialog;
import '../widgets/error_sheet.dart' show ErrorDialog;
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  bool get _showAppleButton {
    if (kIsWeb) return false;
    return Platform.isIOS || Platform.isMacOS;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthCancelled) {
            CancelledDialog.show(
              context,
              providerName: state.providerName,
              onRetry: () {
                final event = state.providerName == 'Google'
                    ? const AuthGoogleSignInRequested()
                    : const AuthAppleSignInRequested();
                context.read<AuthBloc>().add(event);
              },
            );
          }
          if (state is AuthFailure) {
            ErrorDialog.show(
              context,
              message: state.message,
              onRetry: () => context.read<AuthBloc>().add(
                state.providerName == 'Apple'
                    ? const AuthAppleSignInRequested()
                    : const AuthGoogleSignInRequested(),
              ),
            );
          }
        },
        child: SafeArea(
          child: Column(
            children: [
              // Upper half — branding
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _LogoMark(),

                      // const SizedBox(height: 4),
                      // // const Text(
                      // //   'GuzoMy',
                      // //   style: TextStyle(
                      // //     fontFamily: 'Manrope',
                      // //     fontSize: 32,
                      // //     fontWeight: FontWeight.w800,
                      // //     color: AppColors.textPrimary,
                      // //     letterSpacing: -1.0,
                      // //   ),
                      // // ),
                      Text(
                        l10n(context).peerToPeerDelivery,
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textTertiary,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Lower section — auth controls
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 52),
                child: BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final isLoading = state is AuthLoading;
                    final l = l10n(context);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l.authTitle,
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.8,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l.authSubtitle,
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Google button
                        SocialSignInButton(
                          label: l.continueWithGoogle,
                          icon: _GoogleIcon(),
                          onPressed: isLoading
                              ? null
                              : () => context.read<AuthBloc>().add(
                                  const AuthGoogleSignInRequested(),
                                ),
                        ),

                        if (_showAppleButton) ...[
                          const SizedBox(height: 12),
                          SocialSignInButton(
                            label: l.continueWithApple,
                            icon: const Icon(
                              Icons.apple,
                              color: Colors.white,
                              size: 22,
                            ),
                            onPressed: isLoading
                                ? null
                                : () => context.read<AuthBloc>().add(
                                    const AuthAppleSignInRequested(),
                                  ),
                            isDark: true,
                          ),
                        ],

                        if (isLoading) ...[
                          const SizedBox(height: 20),
                          const Center(
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 28),
                        _TermsText(),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoMark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Image.asset('assets/logo-long.png', height: 150);
  }
}

class _GoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Text(
          'G',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF4285F4),
          ),
        ),
      ),
    );
  }
}

class _TermsText extends StatelessWidget {
  Future<void> _launch(String url, BuildContext context) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
      fontFamily: 'Manrope',
      fontSize: 12,
      color: AppColors.textTertiary,
      height: 1.6,
    );
    const linkStyle = TextStyle(
      fontFamily: 'Manrope',
      fontSize: 12,
      color: AppColors.primary,
      fontWeight: FontWeight.w600,
      height: 1.6,
    );

    final l = l10n(context);
    return Text.rich(
      TextSpan(
        style: style,
        children: [
          TextSpan(text: l.termsPrefix),
          WidgetSpan(
            child: GestureDetector(
              onTap: () => _launch(
                'https://docs.google.com/document/d/1AF9gD_FQsQw1BUQCysla-drK_lYR32oqDb5k2ekbGGo/edit',
                context,
              ),
              child: Text(l.termsOfService, style: linkStyle),
            ),
          ),
          TextSpan(text: l.and),
          WidgetSpan(
            child: GestureDetector(
              onTap: () => _launch(
                'https://docs.google.com/document/d/1AF9gD_FQsQw1BUQCysla-drK_lYR32oqDb5k2ekbGGo/edit',
                context,
              ),
              child: Text(l.privacyPolicy, style: linkStyle),
            ),
          ),
          const TextSpan(text: '.'),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
