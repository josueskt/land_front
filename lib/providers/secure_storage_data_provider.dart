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
    print('Token leído del dispositivo: $token');

      if (token != null) {
        return token;
      } else {        
   print('Error leyendo el token del dispositivo:');
        throw 'No hay token en el dispositivo';
      }
    } catch (e) {
      rethrow;
    }
  }

 @override
Future<void> saveToken(String token) async {
  try {
    print('Guardando token en el dispositivo: $token');
    await _storage.write(key: _key, value: token);
    print('Token guardado correctamente');
  } catch (e) {
    print('Error al guardar el token: $e');
    rethrow;
  }
}
}
