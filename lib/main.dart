import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'socket_provider.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SocketProvider()),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final socketProvider = Provider.of<SocketProvider>(context);

    Color appBarColor = socketProvider.isConnected
        ? const Color.fromARGB(255, 177, 68, 68)
        : Colors.red;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor,
        title: Text(socketProvider.isConnected ? 'Conectado' : 'Desconectado'),
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
                'Session ID: ${socketProvider.getSessionId}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            Expanded(
              child: ListView.builder(
                itemCount: socketProvider.connectedUsers.length,
                itemBuilder: (context, index) {
                  final user = socketProvider.connectedUsers[index];
                  return ListTile(
                    title: Text('User ID: ${user['id']}'),
                    subtitle: Text(
                        'User Name: ${user['nombre']}'), // Assuming 'nombre' is a field in your user data
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  onPressed: () async {
                    // Solicitar permiso de captura de pantalla
                    var status = await Permission.mediaLibrary.request();
                    if (status.isGranted) {
                      // Permiso concedido, llamar a startScreenShare
                      socketProvider.startScreenShare();
                    } else {
                      // Permiso denegado, muestra un mensaje al usuario
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text('Permiso de captura de pantalla denegado'),
                        ),
                      );
                    }
                  },
                  tooltip: 'Start Screen Share',
                  backgroundColor: Colors.blue,
                  child: const Icon(Icons.screen_share),
                ),
                const SizedBox(width: 20),
                FloatingActionButton(
                  onPressed: socketProvider.stopScreenShare,
                  tooltip: 'Stop Screen Share',
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
        tooltip: socketProvider.isConnected ? 'Connected' : 'Disconnected',
        backgroundColor: socketProvider.isConnected ? Colors.green : Colors.red,
        child: const Icon(Icons.account_tree_outlined),
      ),
    );
  }
}