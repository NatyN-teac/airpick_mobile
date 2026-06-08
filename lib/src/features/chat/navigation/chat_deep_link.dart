import '../../../core/navigation/app_navigator.dart';
import '../screens/chat_screen.dart';

// Step 6: FCM with { refType: MATCH, refId: <matchId> } → open that chat,
// which re-runs the load-history flow for fresh messages.
void handleChatDeepLink(Map<String, dynamic> data) {
  final refType = (data['refType'] ?? data['type'])?.toString().toUpperCase();
  final matchId = (data['refId'] ?? data['matchId'])?.toString();
  if (refType != 'MATCH' || matchId == null || matchId.isEmpty) return;
  final ctx = appNavigatorKey.currentContext;
  if (ctx != null) openChatScreen(ctx, matchId);
}
