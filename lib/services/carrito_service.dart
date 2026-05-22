import 'http_client_service.dart';

class CarritoService {
  final _http = HttpClientService();

  Future<List<dynamic>> listarDetalles(int usuarioId) async {
    final data = await _http.get('/detalles-carrito/carrito/$usuarioId', auth: true);
    return data is List ? data : [];
  }

  Future<void> agregarAlCarrito(int usuarioId, int productoId, String fechaInicio, String fechaFinal) async {
    await _http.post('/detalles-carrito/agregar', {
      'usuarioId': usuarioId,
      'productoId': productoId,
      'fechaInicio': fechaInicio,
      'fechaFinal': fechaFinal,
    }, auth: true);
  }

  Future<void> eliminarItem(int detalleId) async {
    await _http.delete('/detalles-carrito/$detalleId', auth: true);
  }
}
