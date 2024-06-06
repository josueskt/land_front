import 'package:flutter/material.dart';
import 'package:nombre_del_proyecto/providers/login_provider.dart';
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SocketProvider()),
        ChangeNotifierProvider(create: (_) => LoginProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Consumer<SocketProvider>(
          builder: (context, socketProvider, _) {
            // if (socketProvider.isConnected) {
               return const HomeScreen();
            // } else {
             // return LoginScreen();
            //}
          },
        ),
      ),
    );
  }
}