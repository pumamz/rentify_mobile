import '../models/producto.dart';
import 'http_client_service.dart';

class ApiService {
  final _http = HttpClientService();

  Future<List<Producto>> getProductos({int page = 0, int size = 100}) async {
    final data = await _http.get('/productos?page=$page&size=$size', auth: false);
    final List<dynamic> items = data['content'] ?? [];
    return items.map((item) => Producto.fromJson(item)).toList();
  }

  Future<Producto> getProductoPorId(int id) async {
    final data = await _http.get('/productos/$id', auth: false);
    return Producto.fromJson(data);
  }

  Future<void> crearProducto(Map<String, dynamic> fields, List<dynamic>? files) async {
    if (files != null && files.isNotEmpty) {
      final stringFields = fields.map((k, v) => MapEntry(k, v.toString()));
      await _http.postMultipart('/productos', stringFields, files.cast(), auth: true);
    } else {
      final stringFields = fields.map((k, v) => MapEntry(k, v.toString()));
      await _http.post('/productos', stringFields, auth: true);
    }
  }

  Future<void> actualizarProducto(int id, Map<String, dynamic> data) async {
    await _http.put('/productos/$id', data, auth: true);
  }
}
