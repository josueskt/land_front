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
        ? Color.fromARGB(255, 255, 187, 0)
        : Colors.red;

    return Screenshot(
      controller: screenshotController,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: appBarColor,
          title: Text(
            'Session Screen',
            style: TextStyle(
              fontFamily: 'RobotoMono',
              fontWeight: FontWeight.bold,
            ),
          ),
          elevation: 0,
        ),
        drawer: _buildDrawer(context),
        body: _buildBody(context, sessionProvider),
        floatingActionButton:
            _buildFloatingActionButtons(context, sessionProvider),
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
            leading: Icon(Icons.home),
            title: Text("Home", style: TextStyle(fontFamily: 'RobotoMono')),
            onTap: () {
              _home(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.group_add),
            title: Text("Unirse a sesión",
                style: TextStyle(fontFamily: 'RobotoMono')),
            onTap: () {
              _session(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, SessionProvider sessionProvider) {
    return Center(
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
              Text(
                'No image received',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'RobotoMono',
                  fontWeight: FontWeight.bold,
                ),
              ),
            SizedBox(height: 20),
            TextField(
              controller: roomIdController,
              decoration: InputDecoration(
                hintText: 'Enter Room ID',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 20.0),
                hintStyle: TextStyle(fontFamily: 'RobotoMono'),
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
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: TextStyle(fontFamily: 'RobotoMono'),
              ),
              child: Text('unirse a una sala'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButtons(
      BuildContext context, SessionProvider sessionProvider) {
    return Stack(
      children: <Widget>[
        Positioned(
          bottom: 80.0,
          right: 16.0,
          child: FloatingActionButton(
            onPressed: sessionProvider.startSendingImages,
            tooltip: sessionProvider.isConnected ? 'Conectado' : 'Desconectado',
            backgroundColor:
                sessionProvider.isConnected ? Colors.green : Colors.red,
            child: const Icon(Icons.account_tree_outlined),
          ),
        ),
        Positioned(
          bottom: 16.0,
          right: 16.0,
          child: FloatingActionButton(
            onPressed: sessionProvider.stopSendingImages,
            tooltip: 'Stop Sending Images',
            backgroundColor: Colors.blue,
            child: const Icon(Icons.stop),
          ),
        ),
      ],
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
