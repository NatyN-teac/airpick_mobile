import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

enum NotificationType {
  match,
  message,
  proposal,
  delivery,
  payment,
  verification,
  system,
}

extension NotificationTypeX on NotificationType {
  IconData get icon => switch (this) {
        NotificationType.match => Icons.handshake_rounded,
        NotificationType.message => Icons.chat_bubble_rounded,
        NotificationType.proposal => Icons.local_offer_rounded,
        NotificationType.delivery => Icons.local_shipping_rounded,
        NotificationType.payment => Icons.payments_rounded,
        NotificationType.verification => Icons.verified_rounded,
        NotificationType.system => Icons.bolt_rounded,
      };

  Color get color => switch (this) {
        NotificationType.match => AppColors.success,
        NotificationType.message => AppColors.info,
        NotificationType.proposal => AppColors.primary,
        NotificationType.delivery => const Color(0xFF9F7AEA),
        NotificationType.payment => const Color(0xFF38B2AC),
        NotificationType.verification => AppColors.success,
        NotificationType.system => AppColors.warning,
      };
}

class AppNotification {
  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final DateTime time;
  final bool read;
  final String? actorName; // when set, show an avatar with this initial

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.time,
    this.read = false,
    this.actorName,
  });

  AppNotification copyWith({bool? read}) => AppNotification(
        id: id,
        type: type,
        title: title,
        body: body,
        time: time,
        read: read ?? this.read,
        actorName: actorName,
      );

  String get ago {
    final d = DateTime.now().difference(time);
    if (d.inMinutes < 1) return 'now';
    if (d.inMinutes < 60) return '${d.inMinutes}m';
    if (d.inHours < 24) return '${d.inHours}h';
    if (d.inDays < 7) return '${d.inDays}d';
    return '${(d.inDays / 7).floor()}w';
  }
}

// ── Sample data ───────────────────────────────────────────────────────────────

final sampleNotifications = <AppNotification>[
  AppNotification(
    id: '1',
    type: NotificationType.proposal,
    title: 'New proposal received',
    body: 'Samuel K. proposed \$30 to carry your iPhone & Laptop.',
    time: DateTime.now().subtract(const Duration(minutes: 4)),
    actorName: 'Samuel K.',
  ),
  AppNotification(
    id: '2',
    type: NotificationType.match,
    title: "You're matched!",
    body: 'Your request to London is matched with Aisha M.',
    time: DateTime.now().subtract(const Duration(minutes: 38)),
    actorName: 'Aisha M.',
  ),
  AppNotification(
    id: '3',
    type: NotificationType.message,
    title: 'New message',
    body: '“I can deliver within 2 days of arrival.”',
    time: DateTime.now().subtract(const Duration(hours: 2)),
    actorName: 'Carlos R.',
  ),
  AppNotification(
    id: '4',
    type: NotificationType.delivery,
    title: 'In transit',
    body: 'Your Consumer Electronics is now in transit · JFK → LHR.',
    time: DateTime.now().subtract(const Duration(hours: 6)),
    read: true,
  ),
  AppNotification(
    id: '5',
    type: NotificationType.verification,
    title: 'Verification approved',
    body: 'Your account is now verified. You can carry & send freely.',
    time: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
    read: true,
  ),
  AppNotification(
    id: '6',
    type: NotificationType.payment,
    title: 'Payment released',
    body: '\$48.00 was released for your Tokyo Electronics delivery.',
    time: DateTime.now().subtract(const Duration(days: 2)),
    read: true,
  ),
  AppNotification(
    id: '7',
    type: NotificationType.system,
    title: 'Welcome to Airpick ✈️',
    body: 'Set your mode and complete your profile to get started.',
    time: DateTime.now().subtract(const Duration(days: 4)),
    read: true,
  ),
];
