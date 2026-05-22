import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

class HttpClientService {
  static final HttpClientService _instance = HttpClientService._();
  factory HttpClientService() => _instance;
  HttpClientService._();

  String get _baseUrl => AppConfig.apiUrl;

  Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (auth) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  Future<dynamic> get(String path, {bool auth = false}) async {
    final url = Uri.parse('$_baseUrl$path');
    final response = await http.get(url, headers: await _headers(auth: auth));
    return _handleResponse(response);
  }

  Future<dynamic> post(String path, Map<String, dynamic> body, {bool auth = true}) async {
    final url = Uri.parse('$_baseUrl$path');
    final response = await http.post(url, headers: await _headers(auth: auth), body: jsonEncode(body));
    return _handleResponse(response);
  }

  Future<dynamic> put(String path, Map<String, dynamic> body, {bool auth = true}) async {
    final url = Uri.parse('$_baseUrl$path');
    final response = await http.put(url, headers: await _headers(auth: auth), body: jsonEncode(body));
    return _handleResponse(response);
  }

  Future<dynamic> patch(String path, Map<String, dynamic> body, {bool auth = true}) async {
    final url = Uri.parse('$_baseUrl$path');
    final response = await http.patch(url, headers: await _headers(auth: auth), body: jsonEncode(body));
    return _handleResponse(response);
  }

  Future<dynamic> delete(String path, {bool auth = true}) async {
    final url = Uri.parse('$_baseUrl$path');
    final response = await http.delete(url, headers: await _headers(auth: auth));
    return _handleResponse(response);
  }

  Future<dynamic> postMultipart(String path, Map<String, String> fields, List<File> files, {bool auth = true}) async {
    final url = Uri.parse('$_baseUrl$path');
    final request = http.MultipartRequest('POST', url);

    final hdrs = await _headers(auth: auth);
    request.headers.addAll(hdrs);

    request.fields['producto'] = jsonEncode(fields);
    for (final file in files) {
      request.files.add(await http.MultipartFile.fromPath('imagenes', file.path));
    }

    final response = await http.Response.fromStream(await request.send());
    return _handleResponse(response);
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    }
    final body = response.body.isNotEmpty ? jsonDecode(response.body) : {};
    throw HttpException(
      body['message'] ?? 'Error ${response.statusCode}',
      response.statusCode,
    );
  }
}

class HttpException implements Exception {
  final String message;
  final int statusCode;
  HttpException(this.message, this.statusCode);
  @override
  String toString() => 'HTTP $statusCode: $message';
}
