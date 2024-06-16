import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:screenshot/screenshot.dart';

class SessionProvider with ChangeNotifier {
  late IO.Socket socket;
  bool _isConnected = false;
  String? sessionId;
  List<Map<String, dynamic>> _connectedUsers = [];
  int roomId = 0;
  ScreenshotController screenshotController = ScreenshotController();

  bool get isConnected => _isConnected;
  String? get getSessionId => sessionId;
  List<Map<String, dynamic>> get connectedUsers => _connectedUsers;

  SessionProvider({this.roomId = 0});

  Future<void> connectToServer(int roomId) async {
    final storage = FlutterSecureStorage();
    String? token = await storage.read(key: 'token');

    if (token == null) {
      _showToast('No token found');
      return;
    }

    this.roomId = roomId;

    socket =
        IO.io('ws://192.168.28.129:3000/?roomId=$roomId', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
      'extraHeaders': {
        'Authorization': token,
      }
    });

    socket.on('connect', (_) {
      _isConnected = true;
      notifyListeners();
      _showToast('Connected to server');
      _startSendingImages();
    });

    socket.on('conectados', (data) {
      sessionId = data['session']['id'].toString();
      _connectedUsers =
          List<Map<String, dynamic>>.from(data['session']['user']['roles']);
      notifyListeners();
    });

    socket.on('image', (data) {
      // Aquí asumimos que el servidor envía un Uint8List directamente como 'data'
      if (data is Uint8List) {
        _handleReceivedImage(data);
      } else {
        print('Received invalid image data');
      }
    });

    socket.on('disconnect', (_) {
      _isConnected = false;
      notifyListeners();
      _showToast('Disconnected from server');
      _stopSendingImages();
    });
  }

  Uint8List? _receivedImage;

  Uint8List? get receivedImage => _receivedImage;
  void _handleReceivedImage(Uint8List imageData) {
    // Aquí puedes procesar la imagen recibida según tus necesidades
    // Por ejemplo, almacenarla localmente, mostrarla en la interfaz, etc.
    _receivedImage = imageData;
    print('Received image: ${imageData.length} bytes');
    // Notificar a los listeners que ha llegado una nueva imagen
    notifyListeners();
  }

  void _startSendingImages() async {
    while (_isConnected) {
      try {
        Uint8List? imageData = await screenshotController.capture(
          delay: Duration(milliseconds: 1),
        );

        if (imageData != null) {
          socket.emit('sendImage', imageData);
        }

        await Future.delayed(Duration(seconds: 1));
      } catch (e) {
        print('Error capturing screen: $e');
      }
    }
  }

  void _stopSendingImages() {
    // Detener la captura de pantalla si es necesario
  }

  void disconnectFromServer() {
    notifyListeners();
    socket.disconnect();
    _stopSendingImages();
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  Future<void> logout() async {
    disconnectFromServer();
  }

  @override
  void dispose() {
    disconnectFromServer();
    socket.dispose();
    super.dispose();
  }
}
