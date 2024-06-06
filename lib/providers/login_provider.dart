import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:shared_preferences/shared_preferences.dart';

class LoginProvider with ChangeNotifier {
  late IO.Socket socket;

  LoginProvider() {
    connectToSocket();
  }

  void connectToSocket() {
    socket = IO.io('localhost:3000/?roomId=login', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    //  'query': {'roomId': 'login'}
    });

    socket.on('token', (data) async {
      print('Received token: $data');
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data);
      notifyListeners();
    });
  }

  void sendLogin(String username, String password) {
    socket.emit('sendtoken', {
      'nombreUsuario': username,
      'password': password,
    });
  }

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> removeToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }
}