import 'package:flutter/material.dart';
import '../../../core/navigation/app_navigator.dart';
import '../../home/cubit/nav_cubit.dart';
import '../../matches/models/match_models.dart';
import '../screens/chat_screen.dart';

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
    if (ctx != null) {
      openChatScreen(
        ctx,
        matchId,
        welcomeMessage: welcome,
        initialMatch: match,
      );
    }
  });
}
