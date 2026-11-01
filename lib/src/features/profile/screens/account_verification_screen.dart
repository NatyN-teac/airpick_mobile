import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guzomy/l10n/app_localizations.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/support_contact.dart';
import '../../../core/widgets/state_message.dart';
import '../../offers/widgets/airpick_bubble_shell.dart';
import '../cubit/account_verification_cubit.dart';
import '../cubit/current_user_cubit.dart';
import '../models/account_verification.dart';
import '../repository/user_repository.dart';
import '../widgets/profile_sub_screen_app_bar.dart';
import '../widgets/verification_widgets.dart';
import 'verification_capture_screen.dart';

class AccountVerificationScreen extends StatelessWidget {
  const AccountVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => AccountVerificationCubit(
        ctx.read<UserRepository>(),
        ctx.read<CurrentUserCubit>(),
      )..load(),
      child: const _AccountVerificationView(),
    );
  }
}

class _AccountVerificationView extends StatefulWidget {
  const _AccountVerificationView();

  @override
  State<_AccountVerificationView> createState() =>
      _AccountVerificationViewState();
}

class _AccountVerificationViewState extends State<_AccountVerificationView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enterCtrl;
  bool _showSuccess = false;

  /// Re-evaluates the cooldown so the button unlocks once `canRetryAt` passes.
  Timer? _cooldownTicker;

  @override
  void initState() {
    super.initState();
    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..forward();
    _cooldownTicker = Timer.periodic(const Duration(seconds: 30), (_) {
      final v = context.read<AccountVerificationCubit>().state.verification;
      if (mounted && v?.canRetryAt != null) setState(() {});
    });
  }

  @override
  void dispose() {
    _cooldownTicker?.cancel();
    _enterCtrl.dispose();
    super.dispose();
  }

  Future<void> _openCapture(BuildContext context) async {
    final cubit = context.read<AccountVerificationCubit>();
    final submitted = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: const VerificationCaptureScreen(),
        ),
      ),
    );
    if (submitted == true && mounted) setState(() => _showSuccess = true);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.background;

    final l = l10n(context);
    return Scaffold(
      backgroundColor: bg,
      appBar: ProfileSubScreenAppBar(title: l.profileVerification),
      body: BlocConsumer<AccountVerificationCubit, AccountVerificationState>(
        listenWhen: (prev, curr) => false,
        listener: (context, state) {},
        builder: (context, state) {
          if (state.status == AccountVerificationStatus.initial ||
              state.status == AccountVerificationStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state.status == AccountVerificationStatus.failure) {
            return Center(
              child: AppErrorState(
                title: l.avCouldNotLoad,
                message: state.error ?? l.avLoadFailed,
                onRetry: () => context.read<AccountVerificationCubit>().load(),
              ),
            );
          }

          if (state.verification == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          final verification = state.verification!;
          final step = verificationStepFor(verification);
          final rejectionMessage = verification.isRejected
              ? verificationReasonText(l, verification)
              : null;
          final action = _primaryAction(
            context,
            l,
            verification,
            open: () => _openCapture(context),
          );

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.05),
                  end: Offset.zero,
                ).animate(anim),
                child: child,
              ),
            ),
            child: _showSuccess
                ? BubbleSuccessScreen(
                    key: const ValueKey('success'),
                    isDark: isDark,
                    onDismiss: () => Navigator.pop(context),
                    title: l.avSubmittedTitle,
                    subtitle: l.avSubmittedSub,
                  )
                : Stack(
                    key: const ValueKey('content'),
                    children: [
                      RefreshIndicator(
                        color: AppColors.primary,
                        onRefresh: () =>
                            context.read<AccountVerificationCubit>().load(),
                        child: CustomScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          slivers: [
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  20,
                                  12,
                                  20,
                                  0,
                                ),
                                child: FadeTransition(
                                  opacity: _enterCtrl,
                                  child: SlideTransition(
                                    position:
                                        Tween<Offset>(
                                          begin: const Offset(0, 0.04),
                                          end: Offset.zero,
                                        ).animate(
                                          CurvedAnimation(
                                            parent: _enterCtrl,
                                            curve: Curves.easeOutCubic,
                                          ),
                                        ),
                                    child: Column(
                                      children: [
                                        VerificationHero(
                                          verification: verification,
                                          isDark: isDark,
                                        ),
                                        const SizedBox(height: 28),
                                        VerificationStepTimeline(
                                          activeStep: step,
                                          isDark: isDark,
                                        ),
                                        const SizedBox(height: 24),
                                        VerificationChecklistCard(
                                          isDark: isDark,
                                        ),
                                        if (rejectionMessage != null) ...[
                                          const SizedBox(height: 16),
                                          VerificationRejectionCard(
                                            reason: rejectionMessage,
                                            isDark: isDark,
                                          ),
                                        ],
                                        const SizedBox(height: 16),
                                        VerificationTrustRow(isDark: isDark),
                                        const SizedBox(height: 120),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (action != null)
                        _VerificationActionBar(
                          isDark: isDark,
                          label: action.$1,
                          icon: action.$2,
                          onPressed: action.$3,
                        ),
                    ],
                  ),
          );
        },
      ),
    );
  }
}

/// Bottom button for the current state: start, continue, retry, contact
/// support, or a disabled retry while a cooldown runs. Null when there's
/// nothing for the user to do (verified or under review).
(String, IconData, VoidCallback?)? _primaryAction(
  BuildContext context,
  AppLocalizations l,
  AccountVerification v, {
  required VoidCallback open,
}) {
  if (v.isApproved || v.isUnderReview) return null;
  if (v.isLocked) {
    return (
      l.avContactSupport,
      Icons.mail_outline_rounded,
      () => openSupportEmail(context),
    );
  }
  if (v.isCoolingDown()) return (l.avTryAgain, Icons.schedule_rounded, null);
  if (v.isCapturing) {
    return (l.avContinueVerification, Icons.photo_camera_outlined, open);
  }
  if (v.isResubmissionRequested) {
    return (l.avRetakePhotos, Icons.photo_camera_outlined, open);
  }
  if (v.isDeclined) return (l.avTryAgain, Icons.refresh_rounded, open);
  return (l.avStartVerification, Icons.verified_user_outlined, open);
}

class _VerificationActionBar extends StatelessWidget {
  final bool isDark;
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  const _VerificationActionBar({
    required this.isDark,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.darkBackground : AppColors.background;
    final border = isDark ? AppColors.darkBorder : AppColors.border;
    final enabled = onPressed != null;
    final l = l10n(context);

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          12 + MediaQuery.of(context).padding.bottom,
        ),
        decoration: BoxDecoration(
          color: bg,
          border: Border(top: BorderSide(color: border.withValues(alpha: 0.7))),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 52,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: enabled ? AppColors.primaryGradient : null,
                  color: enabled
                      ? null
                      : AppColors.primary.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onPressed,
                    borderRadius: BorderRadius.circular(14),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(icon, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            label,
                            style: const TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l.avPoweredBy,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.darkTextTertiary
                    : AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
