import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class CancelledDialog {
  CancelledDialog._();

  static Future<void> show(
    BuildContext context, {
    required String providerName,
    required VoidCallback onRetry,
  }) {
    final isGoogle = providerName == 'Google';

    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        final isDark = Theme.of(dialogContext).brightness == Brightness.dark;
        final bg = isDark ? AppColors.darkSurface : Colors.white;
        final textPrimary =
            isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
        final textSecondary =
            isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

        return Dialog(
          backgroundColor: bg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 32),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Provider icon + warning badge
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkBackground
                            : AppColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.border,
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: _ProviderIcon(isGoogle: isGoogle, size: 26),
                      ),
                    ),
                    Positioned(
                      bottom: -2,
                      right: -2,
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          shape: BoxShape.circle,
                          border: Border.all(color: bg, width: 2),
                        ),
                        child: const Center(
                          child: Text(
                            '!',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFD97706),
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Title
                Text(
                  '$providerName sign-in cancelled',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: textPrimary,
                  ),
                ),

                const SizedBox(height: 8),

                // Message
                Text(
                  'You closed the sign-in window before it completed. No changes were made.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 13,
                    height: 1.6,
                    color: textSecondary,
                  ),
                ),

                const SizedBox(height: 24),

                // Try again button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      onRetry();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _ProviderIcon(
                            isGoogle: isGoogle, size: 16, onPrimary: true),
                        const SizedBox(width: 8),
                        Text(
                          'Try $providerName again',
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Dismiss button
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: Text(
                      'Maybe later',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ProviderIcon extends StatelessWidget {
  final bool isGoogle;
  final double size;
  final bool onPrimary;

  const _ProviderIcon({
    required this.isGoogle,
    this.size = 26,
    this.onPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isGoogle) {
      return Text(
        'G',
        style: TextStyle(
          fontFamily: 'Manrope',
          fontSize: size * 0.75,
          fontWeight: FontWeight.w800,
          color: onPrimary ? Colors.white : const Color(0xFF4285F4),
        ),
      );
    }
    return Icon(
      Icons.apple,
      size: size,
      color: onPrimary
          ? Colors.white
          : (Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black),
    );
  }
}
