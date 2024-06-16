import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nombre_del_proyecto/providers/login_provider.dart';
import 'package:nombre_del_proyecto/providers/socket_provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
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
            title: const Text('Cerrar Sesión'),
            onTap: () {
              _logout(context);
            },
          ),
          ListTile(
            title: const Text("unirse a secion"),
            onTap: () {
              _secion(context);
            },
          )
        ],
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
