import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nombre_del_proyecto/providers/login_provider.dart';
import 'package:nombre_del_proyecto/providers/secion_provider.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';

class SessionScreen extends StatefulWidget {
  @override
  _SessionScreenState createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  TextEditingController roomIdController = TextEditingController();
  ScreenshotController screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    final sessionProvider = Provider.of<SessionProvider>(context);
    sessionProvider.screenshotController = screenshotController;

    Color appBarColor = sessionProvider.isConnected
        ? Color.fromARGB(255, 78, 255, 42)
        : Colors.red;

    return Screenshot(
      controller: screenshotController,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: appBarColor,
          title: Text('Session Screen'),
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
                title: Text("home"),
                onTap: () {
                  _home(context);
                },
              ),
              ListTile(
                title: Text("unirse a sesion"),
                onTap: () {
                  _session(context);
                },
              )
            ],
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (sessionProvider.receivedImage != null)
                  Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.width * 0.8,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 1.0),
                      borderRadius: BorderRadius.circular(8.0),
                      image: DecorationImage(
                        image: MemoryImage(sessionProvider.receivedImage!),
                        fit: BoxFit.contain,
                      ),
                    ),
                  )
                else
                  Text('No image received'),
                SizedBox(height: 20),
                TextField(
                  controller: roomIdController,
                  decoration: InputDecoration(
                    hintText: 'Enter Room ID',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    int roomId = int.tryParse(roomIdController.text) ?? 0;
                    if (roomId != 0) {
                      Provider.of<SessionProvider>(context, listen: false)
                          .connectToServer(roomId);
                    } else {
                      Fluttertoast.showToast(
                        msg: 'Please enter a valid Room ID',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: Colors.black,
                        textColor: Colors.white,
                      );
                    }
                  },
                  child: Text('Connect to Room'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final provider = Provider.of<LoginProvider>(context, listen: false);
    final sessionProvider =
        Provider.of<SessionProvider>(context, listen: false);

    await sessionProvider.logout();
    provider.logout();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  Future<void> _session(BuildContext context) async {
    Navigator.pushNamedAndRemoveUntil(context, '/session', (route) => false);
  }

  Future<void> _home(BuildContext context) async {
    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
  }
}
