import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:local_auth/local_auth.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final LocalAuthentication _localAuth = LocalAuthentication();

  bool _isAuthenticating = false;
  bool? _canCheckBiometrics;
  List<BiometricType> _availableBiometrics = [];

  @override
  void initState() {
    super.initState();
    _checkBiometricSupport();
  }

  // Verifica si el dispositivo soporta biometría y si puede verificarla
  Future<void> _checkBiometricSupport() async {
    final canCheckBiometrics = await _localAuth.canCheckBiometrics;
    setState(() {
      _canCheckBiometrics = canCheckBiometrics;
    });

    if (canCheckBiometrics) {
      _getAvailableBiometrics();
    }
  }

  // Obtiene los tipos de biometría disponibles (huella, reconocimiento facial, etc.)
  Future<void> _getAvailableBiometrics() async {
    try {
      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      setState(() {
        _availableBiometrics = availableBiometrics;
      });

      if (_availableBiometrics.isEmpty) {
        print("No hay biometría disponible.");
      } else {
        print("Tipos de biometría disponibles: $_availableBiometrics");
      }
    } catch (e) {
      print('Error al obtener biométricos disponibles: $e');
    }
  }

  // Función para autenticar con huella o reconocimiento facial
  Future<void> _authenticateWithBiometrics() async {
    try {
      setState(() {
        _isAuthenticating = true;
      });

      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Autenticación biométrica para iniciar sesión',
        options: AuthenticationOptions(
          stickyAuth: true,
        ),
      );

      setState(() {
        _isAuthenticating = false;
      });

      if (authenticated) {
        print('Autenticación exitosa');
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        print('Autenticación fallida');
        _showErrorDialog('La autenticación falló');
      }
    } catch (e) {
      setState(() {
        _isAuthenticating = false;
      });
      print('Error al intentar autenticar: $e');
      _showErrorDialog('Error al intentar autenticar');
    }
  }

  // Función para hacer login con correo y contraseña
  Future<void> loginUser(String email, String password, BuildContext context) async {
    final url = Uri.parse('http://10.0.2.2:5000/login');

    final Map<String, String> data = {
      'email': email,
      'password': password,
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        print('Login exitoso');
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        print('Error de login: ${response.body}');
        _showErrorDialog('No se pudo iniciar sesión');
      }
    } catch (e) {
      print('Error al hacer la solicitud: $e');
      _showErrorDialog('Hubo un error de conexión, intenta nuevamente');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Iniciar Sesión'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Correo Electrónico'),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Contraseña'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                loginUser(emailController.text, passwordController.text, context);
              },
              child: Text('Iniciar sesión'),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/register');
              },
              child: Text("¿No tienes cuenta? Regístrate aquí"),
            ),
            SizedBox(height: 20),
            _canCheckBiometrics == true
                ? ElevatedButton(
                    onPressed: _isAuthenticating ? null : _authenticateWithBiometrics,
                    child: _isAuthenticating
                        ? CircularProgressIndicator()
                        : Text('Iniciar sesión con huella'),
                  )
                : Text("La autenticación biométrica no está disponible."),
            _availableBiometrics.isNotEmpty
                ? Text("Tipos de biometría disponibles: $_availableBiometrics")
                : Container(),
          ],
        ),
      ),
    );
  }
}
