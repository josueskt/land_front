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
        ? Color.fromARGB(255, 255, 187, 0)
        : Colors.red;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor,
        title: Text(
          "CopyDesk",
          style:
              TextStyle(fontFamily: 'RobotoMono', fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      drawer: _buildDrawer(context),
      body: _buildBody(context, socketProvider),
      floatingActionButton: FloatingActionButton(
        onPressed: socketProvider.connectToServer,
        tooltip: socketProvider.isConnected ? 'Conectado' : 'Desconectado',
        backgroundColor: socketProvider.isConnected ? Colors.green : Colors.red,
        child: const Icon(Icons.account_tree_outlined),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
              image: DecorationImage(
                image: AssetImage('assets/drawer_header_background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontFamily: 'RobotoMono',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Cerrar Sesión',
                style: TextStyle(fontFamily: 'RobotoMono')),
            onTap: () {
              _logout(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.group_add),
            title: Text("Unirse a sesión",
                style: TextStyle(fontFamily: 'RobotoMono')),
            onTap: () {
              _secion(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, SocketProvider socketProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Text(
            socketProvider.isConnected ? 'Conectado pa' : 'Desconectado pa',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: socketProvider.isConnected ? Colors.green : Colors.red,
              fontFamily: 'RobotoMono',
            ),
          ),
          const SizedBox(height: 20),
          if (socketProvider.roomId != 0)
            Text(
              'Session ID: ${socketProvider.roomId}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'RobotoMono',
              ),
            ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: socketProvider.connectedUsers.length,
              itemBuilder: (context, index) {
                final user = socketProvider.connectedUsers[index];
                return Card(
                  elevation: 2,
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(user['nombre'][0]),
                    ),
                    title: Text('User ID: ${user['id']}',
                        style: TextStyle(fontFamily: 'RobotoMono')),
                    subtitle: Text('User Name: ${user['nombre']}',
                        style: TextStyle(fontFamily: 'RobotoMono')),
                  ),
                );
              },
            ),
          ),
          if (socketProvider.receivedImage != null)
            Container(
              margin: EdgeInsets.symmetric(vertical: 20),
              width: MediaQuery.of(context).size.width * 1,
              height: MediaQuery.of(context).size.height * 0.6,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 1.0),
                borderRadius: BorderRadius.circular(8.0),
                image: DecorationImage(
                  image: MemoryImage(socketProvider.receivedImage!),
                  fit: BoxFit.contain,
                ),
              ),
            ),
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
