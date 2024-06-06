import 'dart:math';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import 'package:flutter/material.dart';
// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:fluttertoast/fluttertoast.dart';

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
    connectToServer();
  }

  void connectToServer() {
    String token =
        // 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY1OTJlZDY4LTI3NjQtNDdjOS1hNDdmLWNiMjQwZTJlYjRlYiIsIm5vbWJyZVVzdWFyaW8iOiJqb3N1ZTEiLCJlbWFpbCI6Impvc3Vlc2t0MjJAaG90LmNvbSIsInJvbGVzIjpbImFkbWluIiwidXNlciJdLCJpYXQiOjE3MTcxMzI2MDAsImV4cCI6MTcxNzEzOTgwMH0.ftmQPqY2TGudKp5pi5F21krSdIKP4v2l4NNBfsKXt8c';
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjRlN2E3MTBhLWQxZjEtNDE3ZS1hYjJjLWE1ZTc3ZjFjYTNjMCIsIm5vbWJyZVVzdWFyaW8iOiJ1c2VyIiwiZW1haWwiOiJhY2Nhc0BnbWFpbC5jb20iLCJyb2xlcyI6WyJ1c2VyIl0sImlhdCI6MTcxNzY0MjQ4NSwiZXhwIjoxNzE3NjQ5Njg1fQ.DRW6Lj30sD7TAPYDa8xRZndrvzWO6jFIry_j-WixEmQ';

    var rng = Random();
    roomId = rng.nextInt(100000);

    socket = IO.io('ws://192.168.100.6:3000/?roomId=$roomId', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
      'extraHeaders': {
        'Authorization': token, // Agrega el token aquí
      }
    });

    socket.on('connect', (_) {
      _isConnected = true;
      notifyListeners();
      _showToast('Connected to server');
    });

    socket.on('conectados', (data) {
      // Assuming data is a map with session information and connected users
      sessionId = data['session']['id'].toString();
      _connectedUsers =
          List<Map<String, dynamic>>.from(data['session']['user']['roles']);
      notifyListeners();
    });

    socket.on('disconnect', (_) {
      _isConnected = false;
      notifyListeners();
      _showToast('Disconnected from server');
    });
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

  @override
  void dispose() {
    stopScreenShare();
    socket.dispose();
    super.dispose();
  }
}
