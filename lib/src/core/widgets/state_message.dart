import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final EdgeInsetsGeometry padding;

  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.padding = const EdgeInsets.all(32),
  });

  @override
  Widget build(BuildContext context) {
    return _StateMessage(
      icon: icon,
      title: title,
      message: message,
      iconColor: AppColors.primary,
      iconBackgroundColor: AppColors.primary.withValues(alpha: 0.08),
      padding: padding,
    );
  }
}

class AppErrorState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final VoidCallback onRetry;
  final EdgeInsetsGeometry padding;

  const AppErrorState({
    super.key,
    this.icon = Icons.cloud_off_rounded,
    this.title = 'Something went wrong',
    required this.message,
    required this.onRetry,
    this.padding = const EdgeInsets.all(32),
  });

  @override
  Widget build(BuildContext context) {
    return _StateMessage(
      icon: icon,
      title: title,
      message: message.replaceFirst('Exception: ', ''),
      iconColor: AppColors.error,
      iconBackgroundColor: AppColors.error.withValues(alpha: 0.08),
      padding: padding,
      action: FilledButton(
        onPressed: onRetry,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Retry',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _StateMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Color iconColor;
  final Color iconBackgroundColor;
  final EdgeInsetsGeometry padding;
  final Widget? action;

  const _StateMessage({
    required this.icon,
    required this.title,
    required this.message,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.padding,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.textSecondary;

    return Padding(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: iconBackgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 52, color: iconColor),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 13,
              height: 1.45,
              color: textSecondary,
            ),
          ),
          if (action != null) ...[const SizedBox(height: 18), action!],
        ],
      ),
    );
  }
}
