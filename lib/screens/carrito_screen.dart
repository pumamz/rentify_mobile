import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../services/carrito_service.dart';
import '../services/renta_service.dart';
import '../services/auth_service.dart';

class CarritoScreen extends StatefulWidget {
  const CarritoScreen({super.key});
  @override
  State<CarritoScreen> createState() => _CarritoScreenState();
}

class _CarritoScreenState extends State<CarritoScreen> {
  final _carritoService = CarritoService();
  final _rentaService = RentaService();
  final _authService = AuthService();

  bool _isLoading = true;
  bool _isProcessingCheckout = false;
  List<dynamic> _detalles = [];
  double _totalCarrito = 0.0;

  @override
  void initState() { super.initState(); _cargarCarrito(); }

  String getImagenUrl(String? ruta) {
    if (ruta == null || ruta.isEmpty) return 'https://placehold.co/80x80/6366F1/FFFFFF?text=R';
    if (ruta.startsWith('http')) return ruta;
    return '${AppConfig.apiBaseUrl}$ruta';
  }

  Future<void> _cargarCarrito() async {
    setState(() => _isLoading = true);
    final usuarioId = await _authService.obtenerIdUsuario();
    if (usuarioId == null) { setState(() => _isLoading = false); return; }
    try {
      final detalles = await _carritoService.listarDetalles(usuarioId);
      double total = 0;
      for (final d in detalles) {
        total += (d['producto']?['precio'] ?? 0).toDouble();
      }
      setState(() { _detalles = detalles; _totalCarrito = total; });
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  Future<void> _eliminar(int idDetalle) async {
    try {
      await _carritoService.eliminarItem(idDetalle);
      _cargarCarrito();
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al eliminar')));
    }
  }

  Future<void> _confirmarRenta() async {
    if (_detalles.isEmpty) return;
    setState(() => _isProcessingCheckout = true);

    final usuarioId = await _authService.obtenerIdUsuario();
    if (usuarioId == null) return;

    final detallesRenta = _detalles.map((item) => {
      'productoId': item['producto']['id'],
      'precioUnitario': item['producto']['precio'],
      'fechaEntregaEsperada': item['fechaFinal'] ?? item['fechaInicio'],
      'comentarios': '',
    }).toList();

    try {
      await _rentaService.crearRenta({
        'usuarioId': usuarioId,
        'detalles': detallesRenta,
      });

      for (final item in _detalles) {
        await _carritoService.eliminarItem(item['id']);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Renta confirmada!'), backgroundColor: Colors.green),
        );
        _cargarCarrito();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
    setState(() => _isProcessingCheckout = false);
  }

  @override
  Widget build(BuildContext context) {
    final primary = Color(AppConfig.primaryColor);
    return Scaffold(
      appBar: AppBar(title: const Text('Mi Carrito'), backgroundColor: Colors.white),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _detalles.isEmpty
              ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Carrito vacio', style: TextStyle(fontSize: 18, color: Colors.grey)),
                ]))
              : ListView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount: _detalles.length,
                  itemBuilder: (context, index) {
                    final item = _detalles[index];
                    final producto = item['producto'];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(children: [
                          ClipRRect(borderRadius: BorderRadius.circular(8),
                            child: Image.network(getImagenUrl(producto?['imagenUrl']), width: 70, height: 70, fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 40, color: Colors.grey))),
                          const SizedBox(width: 12),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(producto?['nombre'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            const SizedBox(height: 4),
                            Text('\$${producto?['precio']} / dia', style: TextStyle(color: primary, fontWeight: FontWeight.w600)),
                          ])),
                          IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => _eliminar(item['id'])),
                        ]),
                      ),
                    );
                  },
                ),
      bottomNavigationBar: _detalles.isEmpty || _isLoading ? null : Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
        child: SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Total:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('\$${_totalCarrito.toStringAsFixed(2)}', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primary)),
          ]),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primary, foregroundColor: Colors.white),
              onPressed: _isProcessingCheckout ? null : _confirmarRenta,
              child: _isProcessingCheckout
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Confirmar Renta', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            )),
        ])),
      ),
    );
  }
}
