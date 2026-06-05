import '../../../core/network/api_client.dart';
import '../models/offer_request_models.dart';

class OfferRequestRepository {
  final ApiClient _client;

  OfferRequestRepository(this._client);

  Future<OfferRequestResponse> createOfferRequest(
      CreateOfferRequestRequest request) async {
    final response =
        await _client.post('/offer-requests', request.toJson());
    return OfferRequestResponse.fromJson(_payload(response));
  }

  Future<OfferRequestResponse> updateOfferRequest(
      String id, UpdateOfferRequestRequest request) async {
    final response =
        await _client.patch('/offer-requests/$id', request.toJson());
    return OfferRequestResponse.fromJson(_payload(response));
  }

  Future<List<OfferRequestResponse>> fetchMyOfferRequests() async {
    final response = await _client.get('/offer-requests/me');
    final list = (response['content'] ?? response['data']) as List<dynamic>;
    return list
        .map((e) =>
            OfferRequestResponse.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> deleteOfferRequest(String id) async {
    await _client.delete('/offer-requests/$id');
  }

  // Backend wraps the object under `content`; spec also documents `data`.
  Map<String, dynamic> _payload(Map<String, dynamic> response) =>
      (response['content'] ?? response['data']) as Map<String, dynamic>;
}
