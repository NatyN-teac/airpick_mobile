import '../../../core/network/api_client.dart';
import '../../matches/models/match_models.dart';
import '../models/offer_request_models.dart';
import '../models/proposal_models.dart';

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

  // Carrier view: browse other users' open requests, optionally filtered.
  Future<List<OfferRequestResponse>> browseOfferRequests({
    String? sourceCountry,
    String? destinationCountry,
    String? sourceCity,
  }) async {
    final params = <String, String>{
      if (sourceCountry != null && sourceCountry.isNotEmpty)
        'sourceCountry': sourceCountry,
      if (destinationCountry != null && destinationCountry.isNotEmpty)
        'destinationCountry': destinationCountry,
      if (sourceCity != null && sourceCity.isNotEmpty)
        'sourceCity': sourceCity,
    };
    final query = params.isEmpty
        ? ''
        : '?${params.entries.map((e) => '${e.key}=${Uri.encodeQueryComponent(e.value)}').join('&')}';
    final response = await _client.get('/offer-requests/browse$query');
    final list = (response['content'] ?? response['data']) as List<dynamic>;
    return list
        .map((e) =>
            OfferRequestResponse.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> deleteOfferRequest(String id) async {
    await _client.delete('/offer-requests/$id');
  }

  // Carrier sends a proposal against a request.
  Future<void> createProposal(
      String requestId, CreateProposalRequest request) async {
    await _client.post(
        '/offer-requests/$requestId/proposals', request.toJson());
  }

  // Carrier withdraws a sent proposal.
  Future<void> withdrawProposal(String proposalId) async {
    await _client.delete('/offer-requests/proposals/$proposalId/withdraw');
  }

  // Sender rejects a received proposal.
  Future<void> rejectProposal(String proposalId) async {
    await _client.patchVoid('/offer-requests/proposals/$proposalId/reject');
  }

  // Sender accepts a proposal — creates match + chat.
  Future<MatchResponse> acceptProposal(
    String proposalId,
    AcceptProposalRequest request,
  ) async {
    final response = await _client.post(
      '/offer-requests/proposals/$proposalId/accept',
      request.toJson(),
    );
    final data = response['content'] ?? response['data'];
    if (data is! Map<String, dynamic>) {
      throw Exception('Accept response missing match data.');
    }
    return MatchResponse.fromJson(data);
  }

  // Backend wraps the object under `content`; spec also documents `data`.
  Map<String, dynamic> _payload(Map<String, dynamic> response) =>
      (response['content'] ?? response['data']) as Map<String, dynamic>;
}
