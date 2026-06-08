import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../models/delivery_track_models.dart';

class DeliveryTrackCard extends StatelessWidget {
  final TrackedDeliveryItem item;
  final bool isDark;
  final bool viewerIsCarrier;
  final VoidCallback? onTap;
  final double? width;

  const DeliveryTrackCard({
    super.key,
    required this.item,
    required this.isDark,
    required this.viewerIsCarrier,
    this.onTap,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final surface = isDark ? AppColors.darkSurface : Colors.white;
    final daysLabel = item.daysLeftLabel;
    final updated = DateTime.tryParse(item.match.updatedAt ?? '');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.border,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.06),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _GroupChip(group: item.group),
                const Spacer(),
                if (daysLabel != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _daysBadgeColor(item).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      daysLabel,
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: _daysBadgeColor(item),
                      ),
                    ),
                  )
                else if (updated != null)
                  Text(
                    _relativeTime(updated),
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 10,
                      color: textSecondary,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              item.itemTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: textPrimary,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                if (item.routeLabel != null) ...[
                  Expanded(
                    child: Text(
                      item.routeLabel!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 11,
                        color: textSecondary,
                      ),
                    ),
                  ),
                ] else
                  const Spacer(),
                Text(
                  item.partnerRoleLabel(viewerIsCarrier: viewerIsCarrier),
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DeliveryTrackProgressBar(group: item.group, isDark: isDark),
          ],
        ),
      ),
    );
  }

  Color _daysBadgeColor(TrackedDeliveryItem item) {
    if (item.group == DeliveryTrackGroup.completed) return AppColors.success;
    final days = item.daysUntilDelivery;
    if (days == null) return AppColors.primary;
    if (days <= 0) return AppColors.error;
    if (days <= 2) return AppColors.warning;
    return AppColors.info;
  }

  String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes.clamp(1, 59)}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(dt);
  }
}

class _GroupChip extends StatelessWidget {
  final DeliveryTrackGroup group;
  const _GroupChip({required this.group});

  @override
  Widget build(BuildContext context) {
    final color = switch (group) {
      DeliveryTrackGroup.collected => const Color(0xFFED8936),
      DeliveryTrackGroup.inProgress => AppColors.info,
      DeliveryTrackGroup.completed => AppColors.success,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        group.label,
        style: TextStyle(
          fontFamily: 'Manrope',
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

/// Three-segment delivery progress: picked up → in progress → delivered.
class DeliveryTrackProgressBar extends StatelessWidget {
  final DeliveryTrackGroup group;
  final bool isDark;

  const DeliveryTrackProgressBar({
    super.key,
    required this.group,
    required this.isDark,
  });

  static const _labels = ['Picked up', 'In transit', 'Delivered'];

  @override
  Widget build(BuildContext context) {
    final active = group.activeSteps;
    final track = isDark ? AppColors.darkBorder : const Color(0xFFEEF0F3);
    final fill = switch (group) {
      DeliveryTrackGroup.collected => const Color(0xFFED8936),
      DeliveryTrackGroup.inProgress => AppColors.info,
      DeliveryTrackGroup.completed => AppColors.success,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: List.generate(3, (i) {
            final step = i + 1;
            final isActive = step <= active;
            final isCurrent = step == active;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: i == 0 ? 0 : 4),
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeOut,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isActive ? fill : track,
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: isCurrent
                            ? [
                                BoxShadow(
                                  color: fill.withValues(alpha: 0.35),
                                  blurRadius: 6,
                                ),
                              ]
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 6),
        Row(
          children: List.generate(3, (i) {
            final step = i + 1;
            final isActive = step <= active;
            return Expanded(
              child: Text(
                _labels[i],
                textAlign: i == 0
                    ? TextAlign.left
                    : (i == 2 ? TextAlign.right : TextAlign.center),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 8,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive
                      ? fill
                      : (isDark
                          ? AppColors.darkTextTertiary
                          : AppColors.textTertiary),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
