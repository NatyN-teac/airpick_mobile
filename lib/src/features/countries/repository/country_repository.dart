import '../../../core/network/api_client.dart';
import '../models/country.dart';

class CountryRepository {
  final ApiClient _client;
  List<Country>? _cache;

  CountryRepository(this._client);

  Future<List<Country>> fetchCountries() async {
    if (_cache != null) return _cache!;
    final response = await _client.get('/countries');
    // Backend wraps list responses under `content`; spec also documents `data`.
    final list = (response['content'] ?? response['data']) as List<dynamic>;
    _cache = list
        .map((e) => Country.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    return _cache!;
  }
}
