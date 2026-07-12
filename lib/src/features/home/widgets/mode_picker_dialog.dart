import 'package:flutter/material.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../cubit/user_mode_cubit.dart';

void showModePickerDialog(
  BuildContext context, {
  required UserMode currentMode,
  required ValueChanged<UserMode> onSelect,
}) {
  showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.4),
    builder: (_) => ModePickerDialog(
      currentMode: currentMode,
      onSelect: onSelect,
    ),
  );
}

class ModePickerDialog extends StatelessWidget {
  final UserMode currentMode;
  final ValueChanged<UserMode> onSelect;

  const ModePickerDialog({
    super.key,
    required this.currentMode,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkSurface : Colors.white;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.88, end: 1.0),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutBack,
      builder: (_, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: Dialog(
        backgroundColor: bg,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 32),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.swap_horiz_rounded,
                        size: 18, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n(context).modePickerTitle,
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        l10n(context).modePickerQuestion,
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 11,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ModePickerCards(
                currentMode: currentMode,
                onSelect: onSelect,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ModePickerCards extends StatelessWidget {
  final UserMode currentMode;
  final ValueChanged<UserMode> onSelect;

  const ModePickerCards({
    super.key,
    required this.currentMode,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Expanded(
          child: ModeCard(
            mode: UserMode.sender,
            isActive: currentMode == UserMode.sender,
            isDark: isDark,
            onTap: () => onSelect(UserMode.sender),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ModeCard(
            mode: UserMode.carrier,
            isActive: currentMode == UserMode.carrier,
            isDark: isDark,
            onTap: () => onSelect(UserMode.carrier),
          ),
        ),
      ],
    );
  }
}

class ModeCard extends StatelessWidget {
  final UserMode mode;
  final bool isActive;
  final bool isDark;
  final VoidCallback onTap;

  const ModeCard({
    super.key,
    required this.mode,
    required this.isActive,
    required this.isDark,
    required this.onTap,
  });

  IconData get _icon => mode == UserMode.sender
      ? Icons.inventory_2_rounded
      : Icons.flight_rounded;

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppColors.darkBackground : AppColors.surface;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.07)
              : surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive
                ? AppColors.primary
                : (isDark ? AppColors.darkBorder : AppColors.border),
            width: isActive ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primary.withValues(alpha: 0.12)
                    : (isDark ? AppColors.darkSurface : Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _icon,
                size: 20,
                color: isActive
                    ? AppColors.primary
                    : (isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              mode == UserMode.sender
                  ? l10n(context).modeSender
                  : l10n(context).modeCarrier,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isActive ? AppColors.primary : textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              mode == UserMode.sender
                  ? l10n(context).modeSenderDesc
                  : l10n(context).modeCarrierDesc,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 10,
                color: textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 10),
            AnimatedOpacity(
              opacity: isActive ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded,
                      size: 13, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    l10n(context).active,
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
