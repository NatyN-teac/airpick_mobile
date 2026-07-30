import 'package:flutter/material.dart';
import '../../../core/navigation/app_navigator.dart';
import '../../../core/theme/app_colors.dart';
import '../../home/cubit/nav_cubit.dart';
import '../../matches/models/match_models.dart';
import '../screens/chat_screen.dart';

/// A match that hasn't been accepted yet has no chat room on the backend, so
/// pushing into the chat only lands the user on the dead "pending" screen.
/// Confirm the request inline instead and let them carry on.
void showMatchPendingNotice(BuildContext context) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: const Text(
          'Match request sent — we\'ll open the chat once the carrier accepts.',
          style: TextStyle(fontFamily: 'Manrope'),
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
}

String buildMatchWelcomeMessage(
  MatchResponse match, {
  List<String>? fallbackItemNames,
}) {
  final names = match.matchedItems.isNotEmpty
      ? match.matchedItems.map((i) => i.itemName)
      : (fallbackItemNames ?? const <String>[]);
  final filtered = names.where((n) => n.trim().isNotEmpty).take(3).toList();
  final label =
      filtered.isEmpty ? 'your matched items' : filtered.join(', ');
  return 'Welcome! This chat is for $label. Let\'s coordinate pickup and delivery here.';
}

/// After accepting a proposal: switch to Chats tab and open the match chat.
void navigateToMatchChatAfterAccept({
  required NavCubit navCubit,
  required NavigatorState navigator,
  required MatchResponse match,
  List<String>? fallbackItemNames,
}) {
  final matchId = match.id;
  if (matchId.isEmpty) return;

  final welcome = buildMatchWelcomeMessage(
    match,
    fallbackItemNames: fallbackItemNames,
  );

  navCubit.setTab(1);
  navigator.pop();
  if (navigator.canPop()) navigator.pop();

  WidgetsBinding.instance.addPostFrameCallback((_) {
    final ctx = appNavigatorKey.currentContext;
    if (ctx == null) return;
    // Only push into the room when the backend actually has one. Otherwise the
    // match is still PENDING and the chat screen would render its dead-end
    // "waiting for the carrier" state.
    if (!match.hasAvailableChat) {
      showMatchPendingNotice(ctx);
      return;
    }
    openChatScreen(
      ctx,
      matchId,
      welcomeMessage: welcome,
      initialMatch: match,
    );
  });
}
