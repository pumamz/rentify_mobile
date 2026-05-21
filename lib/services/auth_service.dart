import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Asegúrate de que esta IP sea la de tu laptop
  final String baseUrl = "http://localhost:8080/api/usuarios";

  // 1. Método de Login
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": username, "password": password}),
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        
        // ¡Magia! Guardamos la sesión en el celular
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('usuario_id', userData['id']);
        await prefs.setString('usuario_nombre', userData['nombre'] ?? '');
        
        return {"success": true, "user": userData};
      } else {
        return {"success": false, "message": response.body};
      }
    } catch (e) {
      return {"success": false, "message": "Error de conexión con el servidor"};
    }
  }

  // 2. Método de Registro
  Future<Map<String, dynamic>> registrar(String username, String password, String nombre, String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/registro'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "password": password,
          "nombre": nombre,
          "email": email,
          "rol": "USER" // Por defecto, se registran como clientes
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {"success": true};
      } else {
        return {"success": false, "message": "No se pudo registrar el usuario"};
      }
    } catch (e) {
      return {"success": false, "message": "Error de conexión"};
    }
  }

  // 3. Método para saber si hay alguien logueado (útil para la pantalla de inicio)
  Future<int?> obtenerIdUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('usuario_id');
  }

  // 4. Cerrar sesión
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Borra los datos guardados
  }
}