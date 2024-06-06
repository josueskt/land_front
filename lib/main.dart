import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:nombre_del_proyecto/providers/login_provider.dart';
import 'package:nombre_del_proyecto/providers/secure_storage_data_provider.dart';
import 'package:nombre_del_proyecto/providers/socket_provider.dart';
import 'package:nombre_del_proyecto/screens/home_screen.dart';
import 'package:nombre_del_proyecto/screens/login_screen.dart';


import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final socketProvider = SocketProvider();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: socketProvider),
        ChangeNotifierProvider(
          create: (context) => LoginProvider(
            context,
            SecureStorageDataProvider(storage: const FlutterSecureStorage()),
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: FutureBuilder<bool>(
          future: _hasToken(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Si estamos esperando el resultado del futuro, muestra un widget de carga
              return const CircularProgressIndicator();
            } else {
              // Si el futuro ha completado su ejecución
              if (snapshot.hasData) {
                // Si hay un token en el dispositivo, redirige a la pantalla de inicio
                return snapshot.data! ? HomeScreen() : LoginScreen();
              } else {
                // Si hubo un error al obtener el token, maneja el error según sea necesario
                return const Text('Error obteniendo el token');
              }
            }
          },
        ),
      ),
    );
  }

  Future<bool> _hasToken() async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'token');
    return token != null;
  }
}
