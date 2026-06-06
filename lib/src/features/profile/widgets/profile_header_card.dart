import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../home/cubit/user_mode_cubit.dart';
import '../cubit/current_user_cubit.dart';
import '../models/profile_snapshot.dart';
import 'profile_avatar.dart';

class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return BlocBuilder<CurrentUserCubit, ProfileSnapshot?>(
      builder: (context, profile) {
        return BlocBuilder<UserModeCubit, UserMode>(
          builder: (context, mode) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (profile == null)
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withValues(alpha: 0.1),
                      ),
                      child: const Icon(Icons.person_outline_rounded,
                          color: AppColors.primary, size: 32),
                    )
                  else
                    ProfileAvatar(profile: profile),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile?.fullName ?? 'Guest',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: textPrimary,
                            letterSpacing: -0.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          mode.label,
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: textSecondary,
                            height: 1.2,
                          ),
                        ),
                        Text(
                          (profile?.isVerified ?? false)
                              ? 'Verified'
                              : 'Unverified',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                            color: (profile?.isVerified ?? false)
                                ? AppColors.success
                                : (isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textTertiary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
