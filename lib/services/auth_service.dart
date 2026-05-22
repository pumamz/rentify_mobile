import 'package:shared_preferences/shared_preferences.dart';
import 'http_client_service.dart';

class AuthService {
  final _http = HttpClientService();

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final data = await _http.post('/auth/login', {
        'username': username,
        'password': password,
      }, auth: false);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token'] ?? '');
      await prefs.setString('refreshToken', data['refreshToken'] ?? '');
      await prefs.setInt('usuario_id', data['usuario']['id']);
      await prefs.setString('usuario_nombre', data['usuario']['nombre'] ?? '');
      await prefs.setString('usuario_rol', data['usuario']['rol'] ?? 'USER');

      return {'success': true, 'user': data['usuario']};
    } on HttpException catch (e) {
      return {'success': false, 'message': e.message};
    } catch (e) {
      return {'success': false, 'message': 'Error de conexion'};
    }
  }

  Future<Map<String, dynamic>> registrar(String username, String password, String nombre, String email) async {
    try {
      final data = await _http.post('/auth/registro', {
        'username': username,
        'password': password,
        'nombre': nombre,
        'email': email,
      }, auth: false);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token'] ?? '');
      await prefs.setString('refreshToken', data['refreshToken'] ?? '');
      await prefs.setInt('usuario_id', data['usuario']['id']);
      await prefs.setString('usuario_nombre', data['usuario']['nombre'] ?? '');
      await prefs.setString('usuario_rol', data['usuario']['rol'] ?? 'USER');

      return {'success': true};
    } on HttpException catch (e) {
      return {'success': false, 'message': e.message};
    } catch (e) {
      return {'success': false, 'message': 'Error de conexion'};
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('usuario_id') != null;
  }

  Future<bool> isAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('usuario_rol') == 'ADMIN';
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
