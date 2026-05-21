import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/producto.dart';

class ApiService {
  final String baseUrl = "https://api-rentify-production.up.railway.app/api/v1";

  Future<List<Producto>> getProductos() async {
    final response = await http.get(Uri.parse('$baseUrl/productos'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<dynamic> items = data['content'] ?? [];
      return items.map((item) => Producto.fromJson(item)).toList();
    } else {
      throw Exception("Error al conectar con la API: ${response.statusCode}");
    }
  }

  Future<void> crearProducto(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/productos'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Error al crear producto");
    }
  }
}
