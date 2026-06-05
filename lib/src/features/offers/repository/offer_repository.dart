import '../models/offer_models.dart';
import '../../../core/network/api_client.dart';

class OfferRepository {
  final ApiClient _client;

  OfferRepository(this._client);

  Future<void> createOffer(CreateOfferRequest request) async {
    await _client.post('/offers', request.toJson());
  }
}
