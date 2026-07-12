import 'package:logger/logger.dart';

import '../models/offer_models.dart';
import '../models/offer_response.dart';
import '../../../core/network/api_client.dart';

class OfferRepository {
  final ApiClient _client;

  OfferRepository(this._client);

  Future<OfferResponse?> createOffer(CreateOfferRequest request) async {
    final response = await _client.post('/offers', request.toJson());
    final data = (response['content'] ?? response['data']);
    return data is Map<String, dynamic> ? OfferResponse.fromJson(data) : null;
  }

  // GET /api/v1/offers/browse — open offers from other carriers.
  Future<List<OfferResponse>> browseOffers() async {
    final response = await _client.get('/offers/browse');
    final list =
        (response['content'] ?? response['data'] ?? []) as List<dynamic>;
    return list
        .map((e) => OfferResponse.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // GET /api/v1/matches/me/track/carrier/search?sourceCountry=...
  Future<List<OfferResponse>> searchCarrierOffers({
    String? sourceCountry,
    String? sourceCity,
    String? destinationCountry,
  }) async {
    final params = <String, String>{
      if (sourceCountry != null && sourceCountry.isNotEmpty)
        'sourceCountry': sourceCountry.trim(),
      if (sourceCity != null && sourceCity.isNotEmpty)
        'sourceCity': sourceCity.trim(),
      if (destinationCountry != null && destinationCountry.isNotEmpty)
        'destinationCountry': destinationCountry.trim(),
    };

    final query = params.isEmpty
        ? ''
        : '?${params.entries.map((e) => '${e.key}=${Uri.encodeQueryComponent(e.value)}').join('&')}';
    final response = await _client.get(
      '/matches/me/track/carrier/search$query',
    );
    final resultJson = _searchBucketItems(response, nestedKey: 'offer');
    final results = resultJson
        .map((json) => OfferResponse.fromJson(json))
        .toList();
    return results;
  }

  List<Map<String, dynamic>> _searchBucketItems(
    Map<String, dynamic> response, {
    required String nestedKey,
  }) {
    final body = response['content'] ?? response['data'] ?? [];
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
          final nested = item[nestedKey];
          if (nested is Map<String, dynamic>) return nested;
          return item;
        })
        .whereType<Map<String, dynamic>>()
        .toList();
  }

  // GET /api/v1/offers/me — the carrier's own offers.
  Future<List<OfferResponse>> fetchMyOffers() async {
    final response = await _client.get('/offers/me');
    final list =
        (response['content'] ?? response['data'] ?? []) as List<dynamic>;
    return list
        .map((e) => OfferResponse.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // PATCH /api/v1/offers/{offerId} — returns the full updated offer.
  Future<OfferResponse> updateOffer(
    String id,
    UpdateOfferRequest request,
  ) async {
    final response = await _client.patch('/offers/$id', request.toJson());
    final data =
        (response['content'] ?? response['data']) as Map<String, dynamic>;
    return OfferResponse.fromJson(data);
  }

  Future<void> deleteOffer(String id) async {
    await _client.delete('/offers/$id');
  }
}
