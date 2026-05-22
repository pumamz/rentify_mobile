import '../models/categoria.dart';
import 'http_client_service.dart';

class CategoriaService {
  final _http = HttpClientService();

  Future<List<Categoria>> listarCategorias({int page = 0, int size = 50}) async {
    final data = await _http.get('/categorias?page=$page&size=$size', auth: false);
    final List<dynamic> items = data['content'] ?? [];
    return items.map((c) => Categoria.fromJson(c)).toList();
  }

  Future<void> crearCategoria(String nombre) async {
    await _http.post('/categorias', {'nombre': nombre}, auth: true);
  }
}
