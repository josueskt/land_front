import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nombre_del_proyecto/providers/login_provider.dart';
import 'package:nombre_del_proyecto/providers/socket_provider.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final socketProvider = Provider.of<SocketProvider>(context);

    Color appBarColor = socketProvider.isConnected
        ? Color.fromARGB(255, 78, 255, 42)
        : Colors.red;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor,
        title: Text("CopyDesk"),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: Text('Cerrar Sesión'),
              onTap: () {
                _logout(context);
              },
            ),
            ListTile(
              title: Text("unirse a secion"),
              onTap: () {
                _secion(context);
              },
            )
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Text(
              socketProvider.isConnected ? 'Conectado pa' : 'Desconectado pa',
              style: TextStyle(
                fontSize: 16,
                color: socketProvider.isConnected ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 20),
            if (socketProvider.getSessionId != null)
              Text(
                'Session ID: ${socketProvider.roomId}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            Expanded(
              child: ListView.builder(
                itemCount: socketProvider.connectedUsers.length,
                itemBuilder: (context, index) {
                  final user = socketProvider.connectedUsers[index];
                  return ListTile(
                    title: Text('User ID: ${user['id']}'),
                    subtitle: Text('User Name: ${user['nombre']}'),
                  );
                },
              ),
            ),
            if (socketProvider.receivedImage != null)
              Container(
                margin: EdgeInsets.symmetric(vertical: 20),
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.width * 0.8,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 1.0),
                  borderRadius: BorderRadius.circular(8.0),
                  image: DecorationImage(
                    image: MemoryImage(socketProvider.receivedImage!),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  onPressed: () async {
                    var status = await Permission.mediaLibrary.request();
                    if (status.isGranted) {
                      socketProvider.startScreenShare();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text('Permiso de captura de pantalla denegado'),
                        ),
                      );
                    }
                  },
                  tooltip: 'Iniciar Compartir Pantalla',
                  backgroundColor: Colors.blue,
                  child: const Icon(Icons.screen_share),
                ),
                const SizedBox(width: 20),
                FloatingActionButton(
                  onPressed: socketProvider.stopScreenShare,
                  tooltip: 'Detener Compartir Pantalla',
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.stop),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: socketProvider.connectToServer,
        tooltip: socketProvider.isConnected ? 'Conectado' : 'Desconectado',
        backgroundColor: socketProvider.isConnected ? Colors.green : Colors.red,
        child: const Icon(Icons.account_tree_outlined),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final provider = Provider.of<LoginProvider>(context, listen: false);
    final socketProvider = Provider.of<SocketProvider>(context, listen: false);

    await socketProvider.logout();

    provider.logout();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  Future<void> _secion(BuildContext context) async {
    Navigator.pushNamedAndRemoveUntil(context, '/seci', (route) => false);
  }
}
