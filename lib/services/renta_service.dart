import '../models/renta.dart';
import 'http_client_service.dart';

class RentaService {
  final _http = HttpClientService();

  Future<List<Renta>> listarRentas({int page = 0, int size = 50}) async {
    final data = await _http.get('/rentas?page=$page&size=$size', auth: true);
    final List<dynamic> items = data['content'] ?? [];
    return items.map((r) => Renta.fromJson(r)).toList();
  }

  Future<void> devolverProducto(int detalleId, {String? nota}) async {
    final body = <String, dynamic>{};
    if (nota != null) body['nota'] = nota;
    await _http.patch('/rentas/detalle/$detalleId/devolver', body, auth: true);
  }

  Future<void> crearRenta(Map<String, dynamic> renta) async {
    await _http.post('/rentas', renta, auth: true);
  }
}
