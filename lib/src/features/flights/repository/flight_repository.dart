import '../models/flight_models.dart';
import '../../../core/network/api_client.dart';

class FlightRepository {
  final ApiClient _client;

  FlightRepository(this._client);

  Future<FlightResponse> createFlight(CreateFlightRequest request) async {
    final response = await _client.post(
      '/flights',
      request.toJson(),
    );
    return FlightResponse.fromJson(
        response['content'] as Map<String, dynamic>);
  }
}
