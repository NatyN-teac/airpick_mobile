import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
        return AlertDialog(
          backgroundColor: bg,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Log out',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w800,
              color: textPrimary,
            ),
          ),
          content: Text(
            'Are you sure you want to log out of your account?',
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
              child: const Text(
                'Cancel',
                style: TextStyle(fontFamily: 'Manrope'),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text(
                'Log out',
                style: TextStyle(
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
                    title: 'User details',
                    subtitle: 'Update your name and profile info',
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
                    title: 'Account verification',
                    subtitle: 'Verify your identity with a passport',
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
                    title: 'Language',
                    subtitle: 'Choose your preferred language',
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
                    title: 'Mode',
                    subtitle: 'Switch between Sender and Carrier',
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
                    title: 'About',
                    subtitle: 'Learn more about Airpick',
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
                    title: 'Close account',
                    subtitle: 'Permanently delete your account',
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
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Log out',
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.error,
                              ),
                            ),
                            SizedBox(height: 1),
                            Text(
                              'Sign out of your account',
                              style: TextStyle(
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
