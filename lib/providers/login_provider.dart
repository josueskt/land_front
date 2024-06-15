import 'package:flutter/material.dart';
import 'package:nombre_del_proyecto/providers/secure_storage_data_provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class LoginProvider with ChangeNotifier {
  late IO.Socket socket;
  late LocalDataProviderInterface _dataProvider;

  LoginProvider(this._dataProvider) {
    connectToSocket();
  }

  void connectToSocket() {
    socket = IO.io('//192.168.28.129:3000', <String, dynamic>{
      'transports': ['websocket'],
      'query': {'roomId': 'login'}
    });

    socket.on('login', (data) {
      _saveTokenToDataProvider(data['token']);
      notifyListeners();
    });
  }

  void sendLogin(String username, String password) {
    socket.emit('sendtoken', {
      'nombreUsuario': username,
      'password': password,
    });
  }

  Future<void> _saveTokenToDataProvider(String token) async {
    try {
      await _dataProvider.saveToken(token);
      notifyListeners();
    } catch (e) {
      print('Error saving token to data provider: $e');
    }
  }

  Future<void> logout() async {
    try {
      await _dataProvider.deleteToken();
      notifyListeners();
    } catch (e) {
      print('Error al cerrar sesión: $e');
    }
  }

  Future<String?> getToken() async {
    try {
      return await _dataProvider.readToken();
    } catch (e) {
      print('Error checking for token: $e');
      return null;
    }
  }
}
