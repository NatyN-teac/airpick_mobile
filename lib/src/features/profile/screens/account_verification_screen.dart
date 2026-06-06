import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/storage/token_storage.dart';
import '../../../core/theme/app_colors.dart';
import '../cubit/account_verification_cubit.dart';
import '../cubit/current_user_cubit.dart';
import '../models/account_verification.dart';
import '../repository/user_repository.dart';
import '../widgets/profile_sub_screen_app_bar.dart';

class AccountVerificationScreen extends StatefulWidget {
  const AccountVerificationScreen({super.key});

  @override
  State<AccountVerificationScreen> createState() =>
      _AccountVerificationScreenState();
}

class _AccountVerificationScreenState extends State<AccountVerificationScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => AccountVerificationCubit(
        ctx.read<UserRepository>(),
        ctx.read<TokenStorage>(),
        ctx.read<CurrentUserCubit>(),
      )..load(),
      child: const _AccountVerificationView(),
    );
  }
}

class _AccountVerificationView extends StatelessWidget {
  const _AccountVerificationView();

  Future<void> _pickAndUpload(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    try {
      final file = await picker.pickImage(
        source: source,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 85,
      );
      if (file != null && context.mounted) {
        await context
            .read<AccountVerificationCubit>()
            .uploadPassport(File(file.path));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Passport uploaded. Review may take 1–2 business days.',
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.success,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not select image.')),
        );
      }
    }
  }

  void _showUploadOptions(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBorder : AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Upload passport',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _UploadOption(
                      icon: Icons.photo_library_outlined,
                      label: 'Gallery',
                      onTap: () {
                        Navigator.pop(ctx);
                        _pickAndUpload(context, ImageSource.gallery);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _UploadOption(
                      icon: Icons.camera_alt_outlined,
                      label: 'Camera',
                      onTap: () {
                        Navigator.pop(ctx);
                        _pickAndUpload(context, ImageSource.camera);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.background;

    return Scaffold(
      backgroundColor: bg,
      appBar: const ProfileSubScreenAppBar(title: 'Account verification'),
      body: BlocConsumer<AccountVerificationCubit, AccountVerificationState>(
        listener: (context, state) {
          if (state.error != null &&
              state.status != AccountVerificationStatus.uploading) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!)),
            );
          }
        },
        builder: (context, state) {
          if (state.status == AccountVerificationStatus.loading ||
              state.status == AccountVerificationStatus.initial) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state.status == AccountVerificationStatus.failure) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        size: 48, color: AppColors.error),
                    const SizedBox(height: 12),
                    Text(
                      state.error ?? 'Failed to load verification status.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontFamily: 'Manrope'),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () =>
                          context.read<AccountVerificationCubit>().load(),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Retry',
                          style: TextStyle(fontFamily: 'Manrope')),
                    ),
                  ],
                ),
              ),
            );
          }

          final verification = state.verification!;
          final uploading =
              state.status == AccountVerificationStatus.uploading;

          return Stack(
            children: [
              RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () =>
                    context.read<AccountVerificationCubit>().load(),
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    _StatusCard(verification: verification, isDark: isDark),
                    const SizedBox(height: 16),
                    _UploadCard(
                      verification: verification,
                      isDark: isDark,
                      onUpload: verification.isApproved ||
                              verification.isUnderReview ||
                              verification.isPermanentlyBlocked
                          ? null
                          : () => _showUploadOptions(context),
                    ),
                    if (verification.isRejected &&
                        verification.rejectionReason != null &&
                        verification.rejectionReason!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _RejectionCard(
                        reason: verification.rejectionReason!,
                        isDark: isDark,
                      ),
                    ],
                    const SizedBox(height: 16),
                    _InfoCard(isDark: isDark),
                  ],
                ),
              ),
              if (uploading)
                ColoredBox(
                  color: Colors.black.withValues(alpha: 0.25),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: AppColors.primary),
                        SizedBox(height: 12),
                        Text(
                          'Uploading passport…',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final AccountVerification verification;
  final bool isDark;

  const _StatusCard({required this.verification, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final (color, icon, title, subtitle) = switch (true) {
      _ when verification.isApproved || verification.isVerified => (
          AppColors.success,
          Icons.verified_user_rounded,
          'Verified',
          'Your account has been approved.',
        ),
      _ when verification.isUnderReview => (
          AppColors.warning,
          Icons.hourglass_top_rounded,
          'Under review',
          'We are reviewing your passport. This may take 1–2 business days.',
        ),
      _ when verification.isRejected => (
          AppColors.error,
          Icons.cancel_outlined,
          'Rejected',
          verification.isPermanentlyBlocked
              ? 'Maximum resubmissions reached. Contact support.'
              : 'Please upload a clearer passport photo.',
        ),
      _ => (
          AppColors.warning,
          Icons.info_outline_rounded,
          'Not verified',
          'Upload your passport to verify your account.',
        ),
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 13,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                    height: 1.4,
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

class _UploadCard extends StatelessWidget {
  final AccountVerification verification;
  final bool isDark;
  final VoidCallback? onUpload;

  const _UploadCard({
    required this.verification,
    required this.isDark,
    this.onUpload,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? AppColors.darkSurface : Colors.white;
    final canUpload = onUpload != null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.badge_outlined,
            size: 48,
            color: canUpload ? AppColors.primary : AppColors.textDisabled,
          ),
          const SizedBox(height: 12),
          Text(
            'Passport / ID',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            canUpload
                ? 'Upload a clear photo of your passport or government ID.'
                : verification.isApproved
                    ? 'Your document has been verified.'
                    : 'Your document is being reviewed.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 13,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          if (canUpload) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onUpload,
                icon: const Icon(Icons.upload_rounded, size: 18),
                label: const Text('Upload document'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RejectionCard extends StatelessWidget {
  final String reason;
  final bool isDark;

  const _RejectionCard({required this.reason, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rejection reason',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 14,
              fontWeight: FontWeight.w700,
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
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final bool isDark;

  const _InfoCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded,
              color: AppColors.info, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Verification helps keep Airpick safe. Your document is stored securely and used only for identity checks.',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 13,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UploadOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _UploadOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkBackground : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.border,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 28),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontFamily: 'Manrope')),
          ],
        ),
      ),
    );
  }
}
