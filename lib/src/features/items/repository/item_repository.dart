import '../models/item_models.dart';
import '../../../core/network/api_client.dart';

class ItemRepository {
  final ApiClient _client;
  List<ItemModel>? _cache;

  ItemRepository(this._client);

  Future<List<ItemModel>> fetchItems() async {
    if (_cache != null) return _cache!;
    final response = await _client.get('/items');
    print("response is: ${(response)}");
    _cache = (response['content'] as List<dynamic>)
        .map((e) => ItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return _cache!;
  }

  Future<ItemModel> createItem({
    required String name,
    required ItemCategory category,
    required MeasurementType measurementType,
    required MeasurementUnit measurementUnit,
  }) async {
    final response = await _client.post('/items', {
      'name': name,
      'category': category.apiValue,
      'measurementType': measurementType.apiValue,
      'measurementUnit': measurementUnit.apiValue,
    });
    final created =
        ItemModel.fromJson(response['data'] as Map<String, dynamic>);
    _cache = [...?_cache, created];
    return created;
  }
}
