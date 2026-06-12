import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../cubit/notifications_cubit.dart';
import '../cubit/notifications_state.dart';
import '../models/app_notification.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationsCubit, NotificationsState>(
      builder: (context, state) {
        final cubit = context.read<NotificationsCubit>();
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final textPrimary =
            isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
        final textSecondary =
            isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

        final unread = state.items.where((n) => !n.read).toList();
        final earlier = state.items.where((n) => n.read).toList();

        final rows = <Widget>[];
        var animIndex = 0;
        Widget animate(Widget child) =>
            _AnimatedEntry(index: animIndex++, child: child);

        if (unread.isNotEmpty) {
          rows.add(_SectionLabel('New', isDark: isDark, accent: true));
          rows.addAll(unread.map((n) => animate(_NotificationTile(
                notification: n,
                isDark: isDark,
                onTap: () => cubit.markRead(n.id),
              ))));
        }
        if (earlier.isNotEmpty) {
          rows.add(_SectionLabel('Earlier', isDark: isDark));
          rows.addAll(earlier.map((n) => animate(_NotificationTile(
                notification: n,
                isDark: isDark,
                onTap: () {},
              ))));
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 14, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Notifications',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                              color: textPrimary,
                            )),
                        const SizedBox(height: 1),
                        Text(
                          state.unreadCount == 0
                              ? "You're all caught up"
                              : '${state.unreadCount} new update${state.unreadCount == 1 ? '' : 's'}',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 12,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedOpacity(
                    opacity: state.unreadCount == 0 ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 250),
                    child: GestureDetector(
                      onTap: state.unreadCount == 0 ? null : cubit.markAllRead,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.done_all_rounded,
                                size: 14, color: AppColors.primary),
                            SizedBox(width: 5),
                            Text('Mark all read',
                                style: TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                )),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: state.items.isEmpty
                  ? _EmptyState(isDark: isDark)
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(14, 2, 14, 28),
                      children: rows,
                    ),
            ),
          ],
        );
      },
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  final bool isDark;
  final bool accent;
  const _SectionLabel(this.text, {required this.isDark, this.accent = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 14, 6, 8),
      child: Row(
        children: [
          Text(
            text.toUpperCase(),
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
              color: accent
                  ? AppColors.primary
                  : (isDark
                      ? AppColors.darkTextTertiary
                      : AppColors.textTertiary),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Notification tile ─────────────────────────────────────────────────────────

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final bool isDark;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.notification,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final n = notification;
    final surface = isDark ? AppColors.darkSurface : Colors.white;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final textTertiary =
        isDark ? AppColors.darkTextTertiary : AppColors.textTertiary;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        decoration: BoxDecoration(
          color: n.read ? surface : n.type.color.withValues(alpha: 0.055),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: n.read
                ? (isDark ? AppColors.darkBorder : const Color(0xFFEDF1F5))
                : n.type.color.withValues(alpha: 0.18),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: n.type.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(n.type.icon, size: 20, color: n.type.color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          n.title,
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 13.5,
                            fontWeight:
                                n.read ? FontWeight.w600 : FontWeight.w800,
                            color: textPrimary,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        n.ago,
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: textTertiary,
                        ),
                      ),
                      if (!n.read) ...[
                        const SizedBox(width: 7),
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: n.type.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    n.body,
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 12,
                      height: 1.35,
                      color: textSecondary,
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

// ── Staggered entrance ────────────────────────────────────────────────────────

class _AnimatedEntry extends StatefulWidget {
  final int index;
  final Widget child;
  const _AnimatedEntry({required this.index, required this.child});

  @override
  State<_AnimatedEntry> createState() => _AnimatedEntryState();
}

class _AnimatedEntryState extends State<_AnimatedEntry>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );
  late final Animation<double> _fade =
      CurvedAnimation(parent: _c, curve: Curves.easeOut);
  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, 0.10),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 50 * widget.index), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: _fade,
        child: SlideTransition(position: _slide, child: widget.child),
      );
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final bool isDark;
  const _EmptyState({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_none_rounded,
                size: 40, color: AppColors.primary),
          ),
          const SizedBox(height: 18),
          Text('No notifications',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: textPrimary,
              )),
          const SizedBox(height: 6),
          Text('Updates about matches and deliveries land here.',
              style: TextStyle(
                  fontFamily: 'Manrope', fontSize: 13, color: textSecondary)),
        ],
      ),
    );
  }
}
