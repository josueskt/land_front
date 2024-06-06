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
        home: Consumer<SocketProvider>(
          builder: (context, socketProvider, _) {
            if (socketProvider.isConnected) {
              return const HomeScreen();
            } else {
              return LoginScreen();
            }
          },
        ),
      ),
    );
  }
}