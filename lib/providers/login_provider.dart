import 'package:flutter/material.dart';
import 'package:nombre_del_proyecto/core/route/app_router.dart';
import 'package:nombre_del_proyecto/providers/secure_storage_data_provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:nombre_del_proyecto/screens/home_screen.dart'; 

class LoginProvider with ChangeNotifier {
  late IO.Socket socket;
  late LocalDataProviderInterface _dataProvider;



  LoginProvider(BuildContext context, LocalDataProviderInterface dataProvider) { 
    _dataProvider = dataProvider; 
    connectToSocket();
  }

  void connectToSocket() {
    socket = IO.io('//192.168.100.6:3000', <String, dynamic>{
      'transports': ['websocket'],
      'query': {'roomId': 'login'}
    });

socket.on('login', (data) {
 // print(data);
  _saveTokenToDataProvider(data['token']);   // Guarda el token en el proveedor de datos local
  print('pasamos $data');
 // Navega a la pantalla de inicio después de hacer login
      Routes.router.go(Routes.homePath);
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
      print(token);
    } catch (e) {
      print('Error saving token to data provider: $e');
      // Manejar el error según sea necesario
    }
  }

void logout() async {
    try {     
      await _dataProvider.deleteToken();  
      notifyListeners();
       Routes.router.go(Routes.loginPath);
    } catch (e) {
      print('Error al cerrar sesión: $e');       
    }
  }
}
