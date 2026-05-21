import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/producto.dart';

class ApiService {
  // Definimos la base sin el recurso final para evitar duplicados
  final String baseUrl = "http://localhost:8080/api";

  // GET: Obtener todos los productos
  Future<List<Producto>> getProductos() async {
    // Aquí concatenamos correctamente: /api + /productos
    final response = await http.get(Uri.parse('$baseUrl/productos'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((item) => Producto.fromJson(item)).toList();
    } else {
      throw Exception("Error al conectar con la API de Rentify: ${response.statusCode}");
    }
  }

  // POST: Crear un nuevo producto
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