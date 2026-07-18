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
    print("What is this Offer browsse response: ${response}");
    final list =
        (response['content'] ?? response['data'] ?? []) as List<dynamic>;
    print("What COUNT: ${list.length}");
    return list
        .map((e) => OfferResponse.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // GET /api/v1/search/carrier?sourceCountry=&destinationCountry= — open carrier
  // offers (excluding own) whose flight route touches the given country/ies.
  Future<List<OfferResponse>> searchCarrierOffers({
    String? sourceCountry,
    String? destinationCountry,
  }) async {
    final params = <String, String>{
      if (sourceCountry != null && sourceCountry.trim().isNotEmpty)
        'sourceCountry': sourceCountry.trim(),
      if (destinationCountry != null && destinationCountry.trim().isNotEmpty)
        'destinationCountry': destinationCountry.trim(),
    };

    final query = params.isEmpty
        ? ''
        : '?${params.entries.map((e) => '${e.key}=${Uri.encodeQueryComponent(e.value)}').join('&')}';
    final response = await _client.get('/search/carrier$query');
    final list = (response['content'] ?? response['data'] ?? []) as List<dynamic>;
    return list
        .map((e) => OfferResponse.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // GET /api/v1/offers/me — the carrier's own offers.
  // GET /api/v1/offers/{offerId} — single offer, for deep-linking.
  Future<OfferResponse> fetchOfferById(String id) async {
    final response = await _client.get('/offers/$id');
    final data = (response['content'] ?? response['data']) as Map<String, dynamic>;
    return OfferResponse.fromJson(data);
  }

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
