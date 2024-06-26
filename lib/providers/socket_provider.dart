import 'dart:math';
import 'dart:typed_data';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter/material.dart';
// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SocketProvider with ChangeNotifier {
  late IO.Socket socket;
  bool _isConnected = false;
  String? sessionId;
  List<Map<String, dynamic>> _connectedUsers = [];
  int roomId = 0;
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  bool get isConnected => _isConnected;
  String? get getSessionId => sessionId;
  List<Map<String, dynamic>> get connectedUsers => _connectedUsers;

  SocketProvider() {
    roomId;
  }

  Future<void> connectToServer() async {
    final storage = FlutterSecureStorage();
    String? token = await storage.read(key: 'token');

    if (token == null) {
      _showToast('No token found');

      return;
    }

    var rng = Random();
    roomId = rng.nextInt(100000);

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
    });
  }

  Uint8List? _receivedImage;

  Uint8List? get receivedImage => _receivedImage;
  void _handleReceivedImage(Uint8List imageData) {
    // Aquí puedes procesar la imagen recibida según tus necesidades
    // Por ejemplo, almacenarla localmente, mostrarla en la interfaz, etc.
    _receivedImage = imageData;
    // Notificar a los listeners que ha llegado una nueva imagen
    notifyListeners();
  }

  void sendPing() {
    _showToast('Checking server status...');
    socket.emit('ping');
  }

  Future<void> startScreenShare() async {
    _localStream = await navigator.mediaDevices.getDisplayMedia({
      'video': {'cursor': 'always'},
      'audio': false,
    });

    _peerConnection = await createPeerConnection({});
    _peerConnection!.addStream(_localStream!);

    _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
      socket.emit('candidate', {
        'candidate': candidate.candidate,
        'sdpMid': candidate.sdpMid,
        'sdpMLineIndex': candidate.sdpMLineIndex,
      });
    };

    _peerConnection!.onIceConnectionState = (RTCIceConnectionState state) {
      if (state == RTCIceConnectionState.RTCIceConnectionStateDisconnected) {
        stopScreenShare();
      }
    };

    RTCSessionDescription description = await _peerConnection!.createOffer({
      'offerToReceiveAudio': false,
      'offerToReceiveVideo': true,
    });

    await _peerConnection!.setLocalDescription(description);
    socket.emit('offer', {
      'sdp': description.sdp,
      'type': description.type,
    });
  }

  void stopScreenShare() {
    _localStream?.getTracks().forEach((track) {
      track.stop();
    });
    _localStream = null;
    _peerConnection?.close();
    _peerConnection = null;
  }

  void disconnectFromServer() {
    stopScreenShare();
    notifyListeners();
    socket.disconnect();
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
    // Lógica adicional de desconexión si es necesario
  }

  @override
  void dispose() {
    stopScreenShare();
    socket.dispose();
    super.dispose();
  }
}
