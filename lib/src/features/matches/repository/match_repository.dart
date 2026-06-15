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
}
