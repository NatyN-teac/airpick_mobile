import 'package:flutter/material.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/session/session_logout.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/support_contact.dart';

/// Shown when the backend answers `403 AUTH_003 USER_BLOCKED` (for example
/// after a SUSPECTED_FRAUD verification decline). There is no way back into
/// the app: the user can only contact support or sign out.
class BlockedAccountScreen extends StatelessWidget {
  const BlockedAccountScreen({super.key});

  Future<void> _signOut(BuildContext context) async {
    final navigator = Navigator.of(context);
    await performLogout(context);
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l = l10n(context);
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Column(
              children: [
                const Spacer(),
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.error.withValues(alpha: 0.12),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.35),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.block_rounded,
                    size: 40,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  l.blockedTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l.blockedBody,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 14,
                    color: textSecondary,
                    height: 1.5,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => openSupportEmail(context),
                    icon: const Icon(Icons.mail_outline_rounded),
                    label: Text(
                      l.avContactSupport,
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => _signOut(context),
                  child: Text(
                    l.logOut,
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
