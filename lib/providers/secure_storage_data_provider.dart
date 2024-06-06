import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class LocalDataProviderInterface {
  Future<void> saveToken(String token);

  Future<String> readToken();

  Future<void> deleteToken();
}


class SecureStorageDataProvider implements LocalDataProviderInterface {
  SecureStorageDataProvider({
    required FlutterSecureStorage storage,
  }) : _storage = storage;

  final FlutterSecureStorage _storage;
  static const String _key = 'token';
  @override
  Future<void> deleteToken() async {
    try {
      await _storage.delete(key: _key);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> readToken() async {
    try {
      String? token = await _storage.read(key: _key);

      if (token != null) {
        return token;
      } else {
        throw 'No hay token en el dispositivo';
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: _key, value: token);
    } catch (e) {
      rethrow;
    }
  }
}
