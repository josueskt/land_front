import 'package:flutter/material.dart';
import 'package:nombre_del_proyecto/providers/login_provider.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final loginProvider = Provider.of<LoginProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String username = _usernameController.text;
                String password = _passwordController.text;
                loginProvider.sendLogin(username, password);
                _logout(context, loginProvider);
              },
              child: const Text('Login'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _logout(BuildContext context, LoginProvider loginProvider) async {
    await Future.delayed(const Duration(milliseconds: 500));
    String? token = await loginProvider.getToken();

    if (token != null && token.isNotEmpty) {
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    } else {
      // Si no hay token válido, simplemente limpia los campos y no cambia de pantalla
      _usernameController.clear();
      _passwordController.clear();
    }
  }
}
