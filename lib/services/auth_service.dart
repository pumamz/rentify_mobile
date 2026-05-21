import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = "https://api-rentify-production.up.railway.app/api/v1/auth";

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": username, "password": password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token'] ?? '');
        await prefs.setString('refreshToken', data['refreshToken'] ?? '');
        await prefs.setInt('usuario_id', data['usuario']['id']);
        await prefs.setString('usuario_nombre', data['usuario']['nombre'] ?? '');
        return {"success": true, "user": data['usuario']};
      } else {
        final error = jsonDecode(response.body);
        return {"success": false, "message": error['message'] ?? 'Error de autenticacion'};
      }
    } catch (e) {
      return {"success": false, "message": "Error de conexion con el servidor"};
    }
  }

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
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token'] ?? '');
        await prefs.setString('refreshToken', data['refreshToken'] ?? '');
        await prefs.setInt('usuario_id', data['usuario']['id']);
        await prefs.setString('usuario_nombre', data['usuario']['nombre'] ?? '');
        return {"success": true};
      } else {
        final error = jsonDecode(response.body);
        return {"success": false, "message": error['message'] ?? 'No se pudo registrar'};
      }
    } catch (e) {
      return {"success": false, "message": "Error de conexion"};
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<int?> obtenerIdUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('usuario_id');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
