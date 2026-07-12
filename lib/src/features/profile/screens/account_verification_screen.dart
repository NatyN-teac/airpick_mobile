import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/state_message.dart';
import '../../offers/widgets/airpick_bubble_shell.dart';
import '../cubit/account_verification_cubit.dart';
import '../cubit/current_user_cubit.dart';
import '../models/account_verification.dart';
import '../repository/user_repository.dart';
import '../widgets/profile_sub_screen_app_bar.dart';
import '../widgets/veriff_verification_widgets.dart';

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
  String _successTitle = 'Verification submitted!';
  String _successSubtitle =
      'We\'re reviewing your ID. Pull down to refresh for the latest status.';

  @override
  void initState() {
    super.initState();
    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..forward();
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    super.dispose();
  }

  Future<void> _startVeriff(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locale = Localizations.localeOf(context).languageCode;
    final l = l10n(context);
    final cubit = context.read<AccountVerificationCubit>();

    try {
      final outcome = await cubit.startVeriffVerification(
        isDark: isDark,
        languageLocale: locale,
      );
      if (!context.mounted) return;
      switch (outcome) {
        case VeriffFlowOutcome.canceled:
          return;
        case VeriffFlowOutcome.submitted:
          setState(() {
            _successTitle = l.avSubmittedTitle;
            _successSubtitle = l.avSubmittedSub;
            _showSuccess = true;
          });
        case VeriffFlowOutcome.verified:
          setState(() {
            _successTitle = l.avVerifiedTitle;
            _successSubtitle = l.avVerifiedSub;
            _showSuccess = true;
          });
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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
        listenWhen: (prev, curr) =>
            curr.error != null &&
            prev.error != curr.error &&
            curr.status != AccountVerificationStatus.startingVeriff,
        listener: (context, state) {
          // Errors from load() only — Veriff launch errors handled in _startVeriff.
        },
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
          final starting =
              state.status == AccountVerificationStatus.startingVeriff;
          final polling =
              state.status == AccountVerificationStatus.pollingStatus;
          final canStart = canStartVeriff(verification);
          final step = verificationStepFor(verification);
          final rejectionMessage = verification.isRejected
              ? verificationRejectionMessage(verification)
              : null;

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
                    title: _successTitle,
                    subtitle: _successSubtitle,
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
                      if (canStart)
                        _VeriffStartBar(
                          isDark: isDark,
                          loading: starting,
                          label: verification.isRejected == true
                              ? l.avTryAgainVeriff
                              : l.avStartVerification,
                          onStart: starting
                              ? null
                              : () => _startVeriff(context),
                        ),
                      if (starting || polling)
                        ColoredBox(
                          color: Colors.black.withValues(alpha: 0.2),
                          child: Center(
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 40,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 20,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.darkSurface
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const CircularProgressIndicator(
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    starting
                                        ? l.avPreparing
                                        : l.avChecking,
                                    style: TextStyle(
                                      fontFamily: 'Manrope',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: isDark
                                          ? AppColors.darkTextPrimary
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
          );
        },
      ),
    );
  }
}

class _VeriffStartBar extends StatelessWidget {
  final bool isDark;
  final bool loading;
  final String label;
  final VoidCallback? onStart;

  const _VeriffStartBar({
    required this.isDark,
    required this.loading,
    required this.label,
    this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.darkBackground : AppColors.background;
    final border = isDark ? AppColors.darkBorder : AppColors.border;
    final enabled = onStart != null && !loading;
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
                    onTap: enabled ? onStart : null,
                    borderRadius: BorderRadius.circular(14),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.verified_user_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
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
