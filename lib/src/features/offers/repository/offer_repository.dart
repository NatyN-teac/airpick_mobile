import '../models/offer_models.dart';
import '../models/offer_response.dart';
import '../../../core/network/api_client.dart';

class OfferRepository {
  final ApiClient _client;

  OfferRepository(this._client);

  Future<OfferResponse?> createOffer(CreateOfferRequest request) async {
    final response = await _client.post('/offers', request.toJson());
    final data = (response['content'] ?? response['data']);
    return data is Map<String, dynamic>
        ? OfferResponse.fromJson(data)
        : null;
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

  // GET /api/v1/offers/me — the carrier's own offers.
  Future<List<OfferResponse>> fetchMyOffers() async {
    final response = await _client.get('/offers/me');
    final list = (response['content'] ?? response['data'] ?? []) as List<dynamic>;
    return list
        .map((e) => OfferResponse.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // PATCH /api/v1/offers/{offerId} — returns the full updated offer.
  Future<OfferResponse> updateOffer(
      String id, UpdateOfferRequest request) async {
    final response = await _client.patch('/offers/$id', request.toJson());
    final data = (response['content'] ?? response['data']) as Map<String, dynamic>;
    return OfferResponse.fromJson(data);
  }

  Future<void> deleteOffer(String id) async {
    await _client.delete('/offers/$id');
  }
}
