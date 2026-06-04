import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _jwtKey = 'airpick_jwt';
  static const _userIdKey = 'airpick_user_id';

  final FlutterSecureStorage _storage;

  const TokenStorage(this._storage);

  Future<void> saveToken(String token) =>
      _storage.write(key: _jwtKey, value: token);

  Future<String?> getToken() => _storage.read(key: _jwtKey);

  Future<void> saveUserId(String id) =>
      _storage.write(key: _userIdKey, value: id);

  Future<String?> getUserId() => _storage.read(key: _userIdKey);

  Future<void> clear() async {
    await _storage.delete(key: _jwtKey);
    await _storage.delete(key: _userIdKey);
  }
}
