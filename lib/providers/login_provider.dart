import 'package:flutter/material.dart';
import 'package:nombre_del_proyecto/providers/secure_storage_data_provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:nombre_del_proyecto/screens/home_screen.dart'; 

class LoginProvider with ChangeNotifier {
  late IO.Socket socket;
  late BuildContext _context;
  late LocalDataProviderInterface _dataProvider; // Agrega una variable para almacenar el proveedor de datos local

  LoginProvider(BuildContext context, LocalDataProviderInterface dataProvider) { 
    _context = context;
    _dataProvider = dataProvider; // Asigna el proveedor de datos local
    connectToSocket();
  }

  void connectToSocket() {
    socket = IO.io('http://192.168.100.6:3000', <String, dynamic>{
      'transports': ['websocket'],
      'query': {'roomId': 'login'}
    });

socket.on('login', (data) {
  print(data);
  _saveTokenToDataProvider(data['token']); // Guarda el token en el proveedor de datos local
  Navigator.pushReplacement(
    _context,
    MaterialPageRoute(builder: (_) => const HomeScreen()),
  );
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
    } catch (e) {
      print('Error saving token to data provider: $e');
      // Manejar el error según sea necesario
    }
  }
}