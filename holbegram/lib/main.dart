import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/login_screen.dart';


// Fonction principale de l'application qui initialise Firebase et lance l'application
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

// Classe principale de l'application
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Méthode pour construire le widget
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Holbegram',
      theme: ThemeData(),
      home: const LoginScreen(),
    );
  }
}