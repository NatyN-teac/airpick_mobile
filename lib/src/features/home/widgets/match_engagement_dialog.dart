import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/engagement_models.dart';

class MatchEngagementDialog {
  MatchEngagementDialog._();

  static Future<void> show(
    BuildContext context, {
    required EngagementListItem item,
    MatchEngagement? match,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => _MatchEngagementDialogBody(item: item, match: match),
    );
  }
}

class _MatchEngagementDialogBody extends StatelessWidget {
  final EngagementListItem item;
  final MatchEngagement? match;

  const _MatchEngagementDialogBody({
    required this.item,
    required this.match,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkSurface : Colors.white;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Dialog(
      backgroundColor: bg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.handshake_outlined,
                  color: AppColors.success, size: 28),
            ),
            const SizedBox(height: 14),
            Text(
              'Match',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.status.label,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: item.status.color,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              item.title,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              item.subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 12,
                color: textSecondary,
              ),
            ),
            if (match?.chatId != null && match!.chatId!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                'Chat is ready for this match.',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 11.5,
                  color: textSecondary,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBackground : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Delivery and cancellation for matches will be handled in a dedicated flow soon.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 11.5,
                  height: 1.45,
                  color: textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  color: textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
