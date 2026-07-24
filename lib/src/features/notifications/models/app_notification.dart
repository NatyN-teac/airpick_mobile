import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/time_format.dart';

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

  // Deep-link payload from the backend. [rawType] is the backend
  // NotificationType (e.g. "MATCH_DELIVERED"); [refType] + [refId] identify the
  // target entity (e.g. MATCH + matchId). Consumed by routeNotification().
  final String rawType;
  final String? refType;
  final String? refId;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.time,
    this.read = false,
    this.actorName,
    this.rawType = '',
    this.refType,
    this.refId,
  });

  /// Builds a notification from the backend `NotificationResponseDto`.
  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final rawType = (json['type'] ?? '').toString();
    final created = json['createdAt']?.toString();
    return AppNotification(
      id: (json['id'] ?? '').toString(),
      type: _displayTypeFrom(rawType),
      title: (json['title'] ?? '').toString(),
      body: (json['body'] ?? '').toString(),
      time: created != null && created.isNotEmpty
          ? (TimeFormat.parseServerTime(created) ?? DateTime.now())
          : DateTime.now(),
      read: json['isRead'] == true,
      rawType: rawType,
      refType: json['refType']?.toString(),
      refId: json['refId']?.toString(),
    );
  }

  AppNotification copyWith({bool? read}) => AppNotification(
        id: id,
        type: type,
        title: title,
        body: body,
        time: time,
        read: read ?? this.read,
        actorName: actorName,
        rawType: rawType,
        refType: refType,
        refId: refId,
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

// ── Backend type → display bucket ─────────────────────────────────────────────
// Maps the backend NotificationType enum onto the mobile display buckets that
// drive the tile icon + colour. Unknown/new types fall back to `system`.
NotificationType _displayTypeFrom(String backendType) {
  switch (backendType.toUpperCase()) {
    case 'MATCH_CREATED':
    case 'MATCH_ACCEPTED':
    case 'MATCH_REJECTED':
    case 'MATCH_CANCELLED':
      return NotificationType.match;
    case 'MATCH_IN_PROGRESS':
    case 'MATCH_CARRIER_DELIVERED':
    case 'MATCH_DELIVERED':
      return NotificationType.delivery;
    case 'NEW_MESSAGE':
      return NotificationType.message;
    case 'NEW_PROPOSAL':
    case 'PROPOSAL_ACCEPTED':
    case 'PROPOSAL_REJECTED':
    case 'PROPOSAL_WITHDRAWN':
    case 'OFFER_FULLY_MATCHED':
    case 'OFFER_CANCELLED':
    case 'OFFER_REQUEST_CANCELLED':
      return NotificationType.proposal;
    case 'WELCOME':
    case 'ADMIN_BROADCAST':
    default:
      return NotificationType.system;
  }
}
