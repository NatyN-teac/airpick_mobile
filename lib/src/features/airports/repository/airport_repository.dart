import '../models/airport.dart';
import '../../../core/network/api_client.dart';

class AirportRepository {
  final ApiClient _client;
  List<Airport>? _cache;

  AirportRepository(this._client);

  Future<List<Airport>> fetchAirports() async {
    if (_cache != null) return _cache!;
    final response = await _client.get('/airports');
    print('[AirportRepository] response: $response');
    final List<dynamic> data = response['content'] as List<dynamic>;
    _cache = data
        .map((e) => Airport.fromJson(e as Map<String, dynamic>) )
        .where((a) => a.active)
        .toList();
    return _cache!;
  }
}
