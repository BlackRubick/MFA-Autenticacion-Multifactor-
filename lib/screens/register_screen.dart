import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  // Función para registrar al usuario y redirigir a HomeScreen
  Future<void> registerUser(String email, String password, BuildContext context) async {
    final url = Uri.parse('http://10.0.2.2:5000/register'); 

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

      if (response.statusCode == 201) {
        print('Usuario registrado con éxito');
        // Redirige a la pantalla de inicio exitoso
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        print('Error: ${response.body}');
        // Mostrar un mensaje de error si no se registró correctamente
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text('No se pudo registrar el usuario'),
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
    } catch (e) {
      print('Error al hacer la solicitud: $e');
      // Mostrar un mensaje de error en caso de fallo en la conexión
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Hubo un error de conexión, intenta nuevamente'),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Registro"),
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
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Confirmar Contraseña'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (passwordController.text == confirmPasswordController.text) {
                  // Llamar a la función de registro cuando las contraseñas coincidan
                  registerUser(
                    emailController.text,
                    passwordController.text,
                    context,
                  );
                } else {
                  print('Las contraseñas no coinciden');
                  // Mostrar un mensaje de advertencia
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Error'),
                      content: Text('Las contraseñas no coinciden'),
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
              },
              child: Text('Registrarse'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/'); // Volver al login
              },
              child: Text("¿Ya tienes cuenta? Inicia sesión aquí"),
            ),
          ],
        ),
      ),
    );
  }
}
