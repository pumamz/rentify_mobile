import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  // Asegura que Flutter esté listo antes de consultar la memoria del teléfono
  WidgetsFlutterBinding.ensureInitialized();
  
  // Consultamos si ya hay una sesión guardada
  final prefs = await SharedPreferences.getInstance();
  final int? usuarioId = prefs.getInt('usuario_id');

  // Arrancamos la app pasándole la ruta inicial
  runApp(RentifyApp(isLoggedIn: usuarioId != null));
}


class RentifyApp extends StatelessWidget {
  final bool isLoggedIn;

  const RentifyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rentify',
      debugShowCheckedModeBanner: false, // Quita la etiqueta roja de "DEBUG"
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6366F1)),
        useMaterial3: true,
      ),
      // Si está logueado va al Home, si no, al Login
      home: isLoggedIn ? const HomeScreen() : const LoginScreen(),
    );
  }
}