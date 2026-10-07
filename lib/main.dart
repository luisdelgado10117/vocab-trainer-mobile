import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'screens/login_screen.dart';

void main() async {
  // Firebase necesita estar listo ANTES de que la app arranque, por eso
  // main() ahora es async y esperamos su inicialización con await.
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

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
