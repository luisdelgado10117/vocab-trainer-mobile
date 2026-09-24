import 'package:flutter/material.dart';

import 'screens/login_screen.dart';

void main() {
  runApp(const VocabTrainerApp());
}

class VocabTrainerApp extends StatelessWidget {
  const VocabTrainerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Entrenador de vocabulario',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}