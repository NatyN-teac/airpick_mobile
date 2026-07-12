import 'package:flutter/material.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../models/account_verification.dart';

enum VerificationStep { prepare, document, selfie, review }

class VerificationHero extends StatefulWidget {
  final AccountVerification? verification;
  final bool isDark;

  const VerificationHero({
    super.key,
    required this.verification,
    required this.isDark,
  });

  @override
  State<VerificationHero> createState() => _VerificationHeroState();
}

class _VerificationHeroState extends State<VerificationHero>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.verification;
    final isDark = widget.isDark;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final l = l10n(context);

    final (icon, accent, title, subtitle) = switch (true) {
      _ when v?.isApproved == true || v?.isVerified == true => (
          Icons.verified_rounded,
          AppColors.success,
          l.avStatusVerifiedTitle,
          l.avStatusVerifiedBody,
        ),
      _ when v?.isUnderReview == true => (
          Icons.hourglass_top_rounded,
          AppColors.warning,
          l.avStatusReviewTitle,
          l.avStatusReviewBody,
        ),
      _ when v?.isRejected == true => (
          Icons.refresh_rounded,
          AppColors.error,
          v!.verificationStatus.toLowerCase() == 'resubmission_requested'
              ? l.avStatusResubmitTitle
              : l.avStatusDeclinedTitle,
          v.message?.isNotEmpty == true
              ? v.message!
              : l.avStatusRejectedBody,
        ),
      _ => (
          Icons.shield_outlined,
          AppColors.primary,
          l.avStatusDefaultTitle,
          l.avStatusDefaultBody,
        ),
    };

    return Column(
      children: [
        SizedBox(
          width: 120,
          height: 120,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: _pulse,
                builder: (_, child) {
                  final t = Curves.easeOut.transform(_pulse.value);
                  return Transform.scale(
                    scale: 1 + t * 0.22,
                    child: Opacity(opacity: (1 - t) * 0.35, child: child),
                  );
                },
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accent.withValues(alpha: 0.12),
                  ),
                ),
              ),
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      accent.withValues(alpha: 0.18),
                      accent.withValues(alpha: 0.06),
                    ],
                  ),
                  border: Border.all(color: accent.withValues(alpha: 0.35), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.18),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(icon, size: 40, color: accent),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: textPrimary,
            letterSpacing: -0.5,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 14,
            color: textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class VerificationStepTimeline extends StatelessWidget {
  final VerificationStep activeStep;
  final bool isDark;

  const VerificationStepTimeline({
    super.key,
    required this.activeStep,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final l = l10n(context);
    final steps = [
      (l.avStepPrepare, Icons.fact_check_outlined),
      (l.avStepIdScan, Icons.badge_outlined),
      (l.avStepSelfie, Icons.face_retouching_natural_outlined),
      (l.avStepReview, Icons.auto_awesome_outlined),
    ];
    final activeIndex = activeStep.index;

    return Row(
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          if (i > 0)
            Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(1),
                  color: i <= activeIndex
                      ? AppColors.primary.withValues(alpha: 0.55)
                      : (isDark ? AppColors.darkBorder : AppColors.border),
                ),
              ),
            ),
          _StepDot(
            label: steps[i].$1,
            icon: steps[i].$2,
            isActive: i == activeIndex,
            isComplete: i < activeIndex,
            isDark: isDark,
          ),
        ],
      ],
    );
  }
}

class _StepDot extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final bool isComplete;
  final bool isDark;

  const _StepDot({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.isComplete,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final inactive =
        isDark ? AppColors.darkTextTertiary : AppColors.textTertiary;
    final color = isComplete
        ? AppColors.success
        : isActive
            ? AppColors.primary
            : inactive;

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive || isComplete
                ? color.withValues(alpha: 0.12)
                : (isDark ? AppColors.darkSurface : AppColors.surface),
            border: Border.all(
              color: isActive || isComplete
                  ? color.withValues(alpha: 0.45)
                  : (isDark ? AppColors.darkBorder : AppColors.border),
            ),
          ),
          child: Icon(
            isComplete ? Icons.check_rounded : icon,
            size: 18,
            color: color,
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 56,
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive ? color : inactive,
            ),
          ),
        ),
      ],
    );
  }
}

class VerificationChecklistCard extends StatelessWidget {
  final bool isDark;

  const VerificationChecklistCard({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? AppColors.darkSurface : Colors.white;
    final border = isDark ? AppColors.darkBorder : AppColors.border;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final l = l10n(context);

    final items = [
      (Icons.wb_sunny_outlined, l.avTipLighting),
      (Icons.credit_card_outlined, l.avTipId),
      (Icons.face_outlined, l.avTipSelfie),
      (Icons.timer_outlined, l.avTipTime),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.avBeforeStart,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: textPrimary,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 12),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Icon(item.$1, size: 17, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        item.$2,
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 13,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class VerificationTrustRow extends StatelessWidget {
  final bool isDark;

  const VerificationTrustRow({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final chipBg = isDark ? AppColors.darkSurface : AppColors.surface;
    final border = isDark ? AppColors.darkBorder : AppColors.border;
    final text =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final l = l10n(context);

    Widget chip(IconData icon, String label) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: chipBg,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: text,
                ),
              ),
            ],
          ),
        );

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        chip(Icons.lock_outline_rounded, l.avChipEncrypted),
        chip(Icons.verified_user_outlined, 'Veriff'),
        chip(Icons.public_outlined, l.avChip230),
      ],
    );
  }
}

class VerificationRejectionCard extends StatelessWidget {
  final String reason;
  final bool isDark;

  const VerificationRejectionCard({
    super.key,
    required this.reason,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n(context).avWhatWentWrong,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            reason,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 13,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

VerificationStep verificationStepFor(AccountVerification? v) {
  if (v == null) return VerificationStep.prepare;
  if (v.isApproved || v.isVerified) return VerificationStep.review;
  if (v.isUnderReview) return VerificationStep.review;
  if (v.isRejected) return VerificationStep.prepare;
  return VerificationStep.prepare;
}

bool canStartVeriff(AccountVerification? v) {
  if (v == null) return true;
  return v.canStartSession;
}

String? verificationRejectionMessage(AccountVerification v) {
  if (v.message != null && v.message!.isNotEmpty) return v.message;
  if (v.rejectionReason != null && v.rejectionReason!.isNotEmpty) {
    return v.rejectionReason;
  }
  return null;
}
