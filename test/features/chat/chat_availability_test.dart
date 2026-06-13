import 'package:airpick/src/features/chat/cubit/chat_state.dart';
import 'package:airpick/src/features/home/models/engagement_models.dart';
import 'package:airpick/src/features/matches/models/match_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('chat availability', () {
    test('accepted match with a chat id is available', () {
      final match = _matchResponse(status: 'ACCEPTED', chatId: 'chat-1');

      expect(match.hasAvailableChat, isTrue);
    });

    test('pending match is not available even when it has a chat id', () {
      final match = _matchResponse(status: 'PENDING', chatId: 'chat-1');

      expect(match.hasAvailableChat, isFalse);
    });

    test('engagement without a chat id is not available', () {
      final match = MatchEngagement(
        id: 'match-1',
        carrierId: 'carrier-1',
        shipperId: 'shipper-1',
        offerId: 'offer-1',
        status: 'ACCEPTED',
        totalPrice: 10,
        receiverNeeded: false,
        matchedItems: const [],
        createdAt: '',
        updatedAt: '',
      );

      expect(match.hasAvailableChat, isFalse);
    });
  });

  test('ChatState can explicitly clear a stale error', () {
    const state = ChatState(error: 'Chat not found');

    expect(state.copyWith(clearError: true).error, isNull);
  });
}

MatchResponse _matchResponse({
  required String status,
  required String? chatId,
}) {
  return MatchResponse(
    id: 'match-1',
    offerId: 'offer-1',
    status: status,
    totalPrice: 10,
    receiverNeeded: false,
    matchedItems: const [],
    chatId: chatId,
  );
}
