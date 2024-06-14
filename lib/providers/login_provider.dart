import 'package:flutter/material.dart';
import 'package:nombre_del_proyecto/providers/secure_storage_data_provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class LoginProvider with ChangeNotifier {
  late IO.Socket socket;
  late LocalDataProviderInterface _dataProvider;
  late BuildContext _context;

  LoginProvider(BuildContext context, LocalDataProviderInterface dataProvider) {
    _context = context;
    _dataProvider = dataProvider;
    connectToSocket();
  }

  void connectToSocket() {
    socket = IO.io('//192.168.56.129:3000', <String, dynamic>{
      'transports': ['websocket'],
      'query': {'roomId': 'login'}
    });

    socket.on('login', (data) {
      _saveTokenToDataProvider(data['token'], BuildContext);
      notifyListeners();
    });
  }

  void sendLogin(String username, String password, context) {
    socket.emit('sendtoken', {
      'nombreUsuario': username,
      'password': password,
    });
  }

  Future<void> _saveTokenToDataProvider(String token, context) async {
    try {
      await _dataProvider.saveToken(token);
      // Navegar a la pantalla de inicio después de guardar el token
      // ignore: use_build_context_synchronously
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    } catch (e) {
      print('Error saving token to data provider: $e');
    }
  }

  void logout(BuildContext context) async {
    try {
      await _dataProvider.deleteToken();
      notifyListeners();
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } catch (e) {
      print('Error al cerrar sesión: $e');
    }
  }
}
