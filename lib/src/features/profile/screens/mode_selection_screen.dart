import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../home/cubit/user_mode_cubit.dart';
import '../../home/widgets/mode_picker_dialog.dart';
import '../widgets/profile_sub_screen_app_bar.dart';

class ModeSelectionScreen extends StatelessWidget {
  const ModeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.background;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    final l = l10n(context);
    return Scaffold(
      backgroundColor: bg,
      appBar: ProfileSubScreenAppBar(title: l.profileMode),
      body: BlocBuilder<UserModeCubit, UserMode>(
        builder: (context, currentMode) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.modeChooseTitle,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l.modeChooseSubtitle,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 14,
                    color: textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),
                ModePickerCards(
                  currentMode: currentMode,
                  onSelect: (mode) =>
                      context.read<UserModeCubit>().setMode(mode),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
