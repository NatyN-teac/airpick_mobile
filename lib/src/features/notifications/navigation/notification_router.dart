import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/navigation/app_navigator.dart';
import '../../chat/screens/chat_screen.dart';
import '../../home/cubit/engagement_cubit.dart';
import '../../home/cubit/user_mode_cubit.dart';
import '../../home/screens/engagement_activity_screen.dart';
import '../../matches/cubit/delivery_track_cubit.dart';
import '../../matches/repository/match_repository.dart';
import '../../matches/screens/delivery_track_list_screen.dart';
import '../../offer_requests/repository/offer_request_repository.dart';
import '../../offer_requests/screens/offer_requests_screen.dart';
import '../../offers/repository/offer_repository.dart';
import '../../offers/screens/offer_detail_screen.dart';
import '../../profile/repository/user_repository.dart';

/// Central deep-link routing for notifications. Shared by two entry points:
///  1. In-app taps on a tile in NotificationsScreen (rich home context).
///  2. Taps on an FCM push (routed via [handleNotificationDeepLink] at the
///     root navigator context).
///
/// Routing key is the backend `refType` + `refId`, with `type` used to split
/// delivery-related MATCH notifications from chat-related ones:
///   MATCH + (MATCH_IN_PROGRESS|MATCH_DELIVERED) → delivery tracking
///   MATCH + chat-eligible (accepted/in-delivery/…) → chat
///   MATCH + not-yet-eligible (pending/rejected/cancelled) → engagement activity
///   OFFER_REQUEST                               → offer-request detail
///   OFFER                                       → offer detail
///   PROPOSAL / USER / none                      → no navigation
Future<void> routeNotification(
  BuildContext ctx, {
  String? type,
  String? refType,
  String? refId,
}) async {
  final id = refId?.trim();
  if (id == null || id.isEmpty) return;

  final t = (type ?? '').toUpperCase();
  switch ((refType ?? '').toUpperCase()) {
    case 'MATCH':
      if (t == 'MATCH_IN_PROGRESS' ||
          t == 'MATCH_CARRIER_DELIVERED' ||
          t == 'MATCH_DELIVERED') {
        _openDeliveryTracking(ctx);
      } else {
        await _openMatch(ctx, id);
      }
      return;
    case 'OFFER_REQUEST':
      await _openOfferRequest(ctx, id);
      return;
    case 'OFFER':
      await _openOffer(ctx, id);
      return;
    // PROPOSAL, USER, or unknown → no navigation target.
    default:
      return;
  }
}

/// FCM entry point wired to `NotificationService.onDeepLink`. Extracts the
/// deep-link fields from the data payload and routes at the root navigator.
void handleNotificationDeepLink(Map<String, dynamic> data) {
  final ctx = appNavigatorKey.currentContext;
  if (ctx == null) return;
  routeNotification(
    ctx,
    type: data['type']?.toString(),
    refType: data['refType']?.toString(),
    // Fall back to `matchId` for older MATCH-only payloads.
    refId: (data['refId'] ?? data['matchId'])?.toString(),
  );
}

/// Chat is only valid once a match is accepted (has a chat room). For
/// not-yet-eligible matches (pending / rejected / cancelled) we send the user
/// to the engagement activity list — the same guard the engagements list uses
/// — instead of a chat screen that would fail to load.
Future<void> _openMatch(BuildContext ctx, String matchId) async {
  try {
    final match = await ctx.read<MatchRepository>().getMatch(matchId);
    if (!ctx.mounted) return;
    if (match.hasAvailableChat) {
      openChatScreen(ctx, matchId, initialMatch: match);
    } else {
      _openEngagementActivity(ctx);
    }
  } catch (_) {
    // Match couldn't be fetched — fall back to the activity list.
    if (ctx.mounted) _openEngagementActivity(ctx);
  }
}

void _openEngagementActivity(BuildContext ctx) {
  // Reuse the home-scoped cubit when present; otherwise (FCM push at root
  // context) build a self-contained one.
  EngagementCubit? existing;
  try {
    existing = ctx.read<EngagementCubit>();
  } catch (_) {}

  Navigator.of(ctx).push(
    MaterialPageRoute(
      builder: (_) => existing != null
          ? BlocProvider.value(
              value: existing,
              child: const EngagementActivityScreen(),
            )
          : BlocProvider(
              create: (_) => EngagementCubit(
                ctx.read<UserRepository>(),
                ctx.read<OfferRequestRepository>(),
                ctx.read<MatchRepository>(),
              )..load(),
              child: const EngagementActivityScreen(),
            ),
    ),
  );
}

void _openDeliveryTracking(BuildContext ctx) {
  // Reuse the home-scoped cubit when present (in-app tap) so the loaded list
  // shows immediately; otherwise (FCM push at root context) build a
  // self-contained one.
  DeliveryTrackCubit? existing;
  try {
    existing = ctx.read<DeliveryTrackCubit>();
  } catch (_) {}

  if (existing != null) {
    openDeliveryTrackList(ctx);
    return;
  }

  UserMode mode = UserMode.sender;
  try {
    mode = ctx.read<UserModeCubit>().state;
  } catch (_) {}

  Navigator.of(ctx).push(
    MaterialPageRoute(
      builder: (_) => BlocProvider(
        create: (_) =>
            DeliveryTrackCubit(ctx.read<MatchRepository>())..load(mode: mode),
        child: const DeliveryTrackListScreen(),
      ),
    ),
  );
}

Future<void> _openOfferRequest(BuildContext ctx, String id) async {
  try {
    final request =
        await ctx.read<OfferRequestRepository>().fetchOfferRequestById(id);
    if (ctx.mounted) openOfferRequestDetail(ctx, request);
  } catch (_) {/* request may have been removed — nothing to open */}
}

Future<void> _openOffer(BuildContext ctx, String id) async {
  try {
    final offer = await ctx.read<OfferRepository>().fetchOfferById(id);
    if (ctx.mounted) {
      Navigator.of(ctx).push(
        MaterialPageRoute(builder: (_) => OfferDetailScreen(offer: offer)),
      );
    }
  } catch (_) {/* offer may have been removed — nothing to open */}
}
