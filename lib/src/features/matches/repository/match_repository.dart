import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../models/match_models.dart';
import '../models/delivery_track_models.dart';

class MatchRepository {
  final ApiClient _client;

  MatchRepository(this._client);

  Map<String, dynamic> _payload(Map<String, dynamic> response) {
    if (response['success'] == false) {
      throw Exception(apiResponseMessage(response) ?? 'Match request failed.');
    }
    final data = response['content'] ?? response['data'];
    if (data is Map<String, dynamic>) return data;
    if (response.containsKey('matchedItems') ||
        response.containsKey('id') ||
        response.containsKey('matchId')) {
      return response;
    }
    throw Exception('Match data missing from server response.');
  }

  Future<MatchResponse> createMatch(CreateMatchRequest request) async {
    final response = await _client.post('/matches', request.toJson());
    return MatchResponse.fromJson(_payload(response));
  }

  // PATCH /api/v1/matches/{matchId}/accept — carrier accepts a PENDING match.
  Future<MatchResponse> acceptMatch(String matchId) async {
    final response = await _client.patch('/matches/$matchId/accept', const {});
    return MatchResponse.fromJson(_payload(response));
  }

  // PATCH /api/v1/matches/{matchId}/reject — carrier rejects a PENDING match.
  // The backend requires a rejection reason.
  Future<MatchResponse> rejectMatch(String matchId, String reason) async {
    final response = await _client.patch(
      '/matches/$matchId/reject',
      {'rejectionReason': reason},
    );
    return MatchResponse.fromJson(_payload(response));
  }

  // PATCH /api/v1/matches/{matchId}/start — carrier: picked up → in transit
  // (ACCEPTED → IN_PROGRESS). Requires the pickup photo already uploaded.
  Future<MatchResponse> startMatch(String matchId) async {
    final response = await _client.patch('/matches/$matchId/start', const {});
    return MatchResponse.fromJson(_payload(response));
  }

  // PATCH /api/v1/matches/{matchId}/complete — carrier marks delivered
  // (IN_PROGRESS → CARRIER_DELIVERED); awaits sender confirmation.
  Future<MatchResponse> completeMatch(String matchId) async {
    final response = await _client.patch('/matches/$matchId/complete', const {});
    return MatchResponse.fromJson(_payload(response));
  }

  // PATCH /api/v1/matches/{matchId}/confirm-delivery — sender confirms receipt
  // (CARRIER_DELIVERED → COMPLETED).
  Future<MatchResponse> confirmDelivery(String matchId) async {
    final response =
        await _client.patch('/matches/$matchId/confirm-delivery', const {});
    return MatchResponse.fromJson(_payload(response));
  }

  // GET /api/v1/matches/offer/{offerId} — all matches on an offer the caller owns.
  Future<List<MatchResponse>> getMatchesByOffer(String offerId) async {
    final response = await _client.get('/matches/offer/$offerId');
    final list = (response['content'] ?? response['data'] ?? []) as List<dynamic>;
    return list
        .map((e) => MatchResponse.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // GET /api/v1/matches/{matchId}/receiver/id-photo/url — short-lived signed URL
  // to view the receiver's private government-issued ID photo. Participants only.
  // The URL expires (see backend signed-url-duration), so fetch it just before use.
  Future<String> getReceiverIdPhotoUrl(String matchId) async {
    final response =
        await _client.get('/matches/$matchId/receiver/id-photo/url');
    final data = _payload(response);
    final url = data['signedUrl'];
    if (url is String && url.isNotEmpty) return url;
    throw Exception('No receiver ID photo available for this match.');
  }

  // GET /api/v1/matches/{matchId} — full match with items + status.
  Future<MatchResponse> getMatch(String matchId) async {
    final response = await _client.get('/matches/$matchId');
    debugPrint('[Match] GET /matches/$matchId → $response');
    return MatchResponse.fromJson(_payload(response));
  }

  // POST /api/v1/matches/{matchId}/pickup-photo — carrier confirms pickup
  // with a photo (once per match). Advances matched items to COLLECTED.
  Future<MatchResponse> uploadPickupPhoto(String matchId, File photo) async {
    final name = photo.path.split('/').last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(photo.path, filename: name),
    });
    final response = await _client.postMultipart(
      '/matches/$matchId/pickup-photo',
      formData,
    );
    debugPrint('[Match] POST /matches/$matchId/pickup-photo → $response');
    return MatchResponse.fromJson(_payload(response));
  }

  // GET /api/v1/matches/me/track/shipper — active deliveries (shipper view).
  Future<DeliveryTrackResponse> fetchShipperTrack() async {
    final response = await _client.get('/matches/me/track/shipper');
    debugPrint('[Match] GET /matches/me/track/shipper → $response');
    return DeliveryTrackResponse.fromJson(_payload(response));
  }

  // GET /api/v1/matches/me/track/carrier — active deliveries (carrier view).
  Future<DeliveryTrackResponse> fetchCarrierTrack() async {
    final response = await _client.get('/matches/me/track/carrier');
    debugPrint('[Match] GET /matches/me/track/carrier → $response');
    return DeliveryTrackResponse.fromJson(_payload(response));
  }

  // GET /api/v1/matches/me/track/shipper/search?sourceCountry=...
  Future<List<MatchResponse>> searchShipperTrack({
    String? sourceCountry,
    String? sourceCity,
    String? destinationCountry,
  }) async {
    final params = _trackSearchParams(
      sourceCountry: sourceCountry,
      sourceCity: sourceCity,
      destinationCountry: destinationCountry,
    );
    final response = await _client.get(
      '/matches/me/track/shipper/search${_query(params)}',
    );
    debugPrint('[Match] GET /matches/me/track/shipper/search → $response');
    return _matchSearchItems(response).map(MatchResponse.fromJson).toList();
  }

  // GET /api/v1/matches/me/track/carrier/search?sourceCountry=...
  Future<List<MatchResponse>> searchCarrierTrack({
    String? sourceCountry,
    String? sourceCity,
    String? destinationCountry,
  }) async {
    final params = _trackSearchParams(
      sourceCountry: sourceCountry,
      sourceCity: sourceCity,
      destinationCountry: destinationCountry,
    );
    final response = await _client.get(
      '/matches/me/track/carrier/search${_query(params)}',
    );
    debugPrint('[Match] GET /matches/me/track/carrier/search → $response');
    return _matchSearchItems(response).map(MatchResponse.fromJson).toList();
  }

  Map<String, String> _trackSearchParams({
    String? sourceCountry,
    String? sourceCity,
    String? destinationCountry,
  }) => {
    if (sourceCountry != null && sourceCountry.isNotEmpty)
      'sourceCountry': sourceCountry.trim(),
    if (sourceCity != null && sourceCity.isNotEmpty)
      'sourceCity': sourceCity.trim(),
    if (destinationCountry != null && destinationCountry.isNotEmpty)
      'destinationCountry': destinationCountry.trim(),
  };

  String _query(Map<String, String> params) {
    if (params.isEmpty) return '';
    return '?${params.entries.map((e) => '${e.key}=${Uri.encodeQueryComponent(e.value)}').join('&')}';
  }

  List<Map<String, dynamic>> _matchSearchItems(Map<String, dynamic> response) {
    final body = response['content'] ?? response['data'] ?? response;
    final rawItems = body is List<dynamic>
        ? body
        : body is Map<String, dynamic>
        ? const ['completed', 'inProgress', 'collected']
              .expand(
                (key) => body[key] is List<dynamic>
                    ? body[key] as List<dynamic>
                    : const <dynamic>[],
              )
              .toList()
        : const <dynamic>[];

    return rawItems
        .map((item) {
          if (item is! Map<String, dynamic>) return null;
          final nested = item['match'];
          if (nested is Map<String, dynamic>) return nested;
          return item;
        })
        .whereType<Map<String, dynamic>>()
        .toList();
  }
}
