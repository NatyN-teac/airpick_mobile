import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/session/session_logout.dart';
import '../../../core/storage/token_storage.dart';
import '../../../core/theme/app_colors.dart';
import '../cubit/current_user_cubit.dart';
import '../repository/user_repository.dart';
import '../../settings/screens/language_screen.dart';
import '../screens/about_screen.dart';
import '../screens/account_verification_screen.dart';
import '../screens/close_account_screen.dart';
import '../screens/mode_selection_screen.dart';
import '../screens/user_detail_screen.dart';
import '../widgets/profile_header_card.dart';
import '../widgets/profile_menu_tile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final bg = isDark ? AppColors.darkSurface : Colors.white;
        final textPrimary =
            isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
        final l = l10n(ctx);
        return AlertDialog(
          backgroundColor: bg,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            l.logOut,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w800,
              color: textPrimary,
            ),
          ),
          content: Text(
            l.logOutConfirmBody,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 14,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(
                l.cancel,
                style: const TextStyle(fontFamily: 'Manrope'),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                l.logOut,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w700,
                  color: AppColors.error,
                ),
              ),
            ),
          ],
        );
      },
    );
    if (confirmed == true && context.mounted) {
      await performLogout(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.background;
    final l = l10n(context);

    return ColoredBox(
      color: bg,
      child: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => context.read<CurrentUserCubit>().refreshFromServer(
              context.read<UserRepository>(),
              context.read<TokenStorage>(),
            ),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
          children: [
            const ProfileHeaderCard(),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  ProfileMenuTile(
                    icon: Icons.person_outline_rounded,
                    title: l.profileUserDetails,
                    subtitle: l.profileUserDetailsSub,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const UserDetailScreen(),
                      ),
                    ),
                  ),
                  const ProfileMenuDivider(),
                  ProfileMenuTile(
                    icon: Icons.verified_user_outlined,
                    title: l.profileVerification,
                    subtitle: l.profileVerificationSub,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AccountVerificationScreen(),
                      ),
                    ),
                  ),
                  const ProfileMenuDivider(),
                  ProfileMenuTile(
                    icon: Icons.language_outlined,
                    title: l.profileLanguage,
                    subtitle: l.profileLanguageSub,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LanguageScreen(),
                      ),
                    ),
                  ),
                  const ProfileMenuDivider(),
                  ProfileMenuTile(
                    icon: Icons.swap_horiz_outlined,
                    title: l.profileMode,
                    subtitle: l.profileModeSub,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ModeSelectionScreen(),
                      ),
                    ),
                  ),
                  const ProfileMenuDivider(),
                  ProfileMenuTile(
                    icon: Icons.info_outline_rounded,
                    title: l.profileAbout,
                    subtitle: l.profileAboutSub,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AboutScreen(),
                      ),
                    ),
                  ),
                  const ProfileMenuDivider(),
                  ProfileMenuTile(
                    icon: Icons.account_circle_outlined,
                    title: l.profileCloseAccount,
                    subtitle: l.profileCloseAccountSub,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CloseAccountScreen(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: InkWell(
                onTap: () => _confirmLogout(context),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.logout_rounded,
                            color: AppColors.error, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l.logOut,
                              style: const TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.error,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              l.logOutSub,
                              style: const TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 12,
                                color: AppColors.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios_rounded,
                          color: AppColors.error.withValues(alpha: 0.7),
                          size: 14),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
        ),
      ),
    );
  }
}
