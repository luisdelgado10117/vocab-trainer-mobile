import 'package:flutter/material.dart';

/// Por ahora solo confirma que el login funcionó y guarda el token.
/// En la siguiente fase, aquí construiremos la lista de tarjetas pendientes.
class HomeScreen extends StatelessWidget {
  final String token;

  const HomeScreen({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi vocabulario')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 64),
              const SizedBox(height: 16),
              const Text(
                '¡Inicio de sesión exitoso!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Aquí construiremos la lista de tarjetas pendientes.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
