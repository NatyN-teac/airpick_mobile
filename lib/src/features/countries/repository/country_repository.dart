import '../../../core/network/api_client.dart';
import '../../../core/utils/app_logger.dart';
import '../models/country.dart';
import '../models/world_countries.dart';

class CountryRepository {
  final ApiClient _client;
  List<Country>? _cache;

  CountryRepository(this._client);

  /// Every country, sorted by name.
  ///
  /// The backend `/countries` table only has a few countries, so the built-in
  /// world list is merged in. Backend entries win for codes they cover (they
  /// keep the server's id and spelling); the rest use the ISO code as id.
  /// If the request fails, the built-in list alone is returned (not cached,
  /// so the next call retries the server).
  Future<List<Country>> fetchCountries() async {
    if (_cache != null) return _cache!;
    List<Country> server = const [];
    try {
      final response = await _client.get('/countries');
      // Backend wraps list responses under `content`; spec also documents `data`.
      final list = (response['content'] ?? response['data']) as List<dynamic>;
      server = list
          .map((e) => Country.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e, st) {
      appLogger.e('[Countries] fetch failed, using built-in list', e, st);
      return mergeWithWorldCountries(const []);
    }
    return _cache = mergeWithWorldCountries(server);
  }
}

/// [server] countries plus every built-in country whose code isn't already
/// there, sorted by name.
List<Country> mergeWithWorldCountries(List<Country> server) {
  final codes = server.map((c) => c.countryCode.toUpperCase()).toSet();
  return [
    ...server,
    for (final e in worldCountryNames.entries)
      if (!codes.contains(e.key))
        Country(id: e.key, name: e.value, countryCode: e.key),
  ]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
}
