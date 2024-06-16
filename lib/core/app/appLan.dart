import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:nombre_del_proyecto/providers/login_provider.dart';
import 'package:nombre_del_proyecto/providers/secure_storage_data_provider.dart';
import 'package:nombre_del_proyecto/providers/socket_provider.dart';
import 'package:nombre_del_proyecto/screens/home_screen.dart';
import 'package:nombre_del_proyecto/screens/initial_screen.dart';
import 'package:nombre_del_proyecto/screens/login_screen.dart';

import 'package:provider/provider.dart';

import '../../providers/secion_provider.dart';
import '../../screens/secion_screen.dart';

class AppLan extends StatelessWidget {
  const AppLan({super.key});

  @override
  Widget build(BuildContext context) {
    final socketProvider = SocketProvider();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: socketProvider),
        ChangeNotifierProvider(
          create: (context) => LoginProvider(
            SecureStorageDataProvider(storage: const FlutterSecureStorage()),
          ),
        ),
        ChangeNotifierProvider(
            create: (context) => SessionProvider()), // Añade el SessionProvider aquí
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/', // Ruta inicial de la aplicación
        routes: {
          '/': (context) => InitialScreen(), // Ruta de la pantalla inicial
          '/login': (context) => LoginScreen(), // Ruta de la pantalla de login
          '/home': (context) => const HomeScreen(),
          '/session': (context) => SessionScreen(), // Ruta de la pantalla de sesión
        },
      ),
    );
  }
}
