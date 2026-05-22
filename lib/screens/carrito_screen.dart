import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../services/carrito_service.dart';
import '../services/renta_service.dart';
import '../services/auth_service.dart';
import '../services/refresh_notifier.dart';
import 'dart:async';

class CarritoScreen extends StatefulWidget {
  const CarritoScreen({super.key});
  @override
  State<CarritoScreen> createState() => _CarritoScreenState();
}

class _CarritoScreenState extends State<CarritoScreen> {
  final _carrito = CarritoService();
  final _renta = RentaService();
  final _auth = AuthService();
  List<dynamic> _items = [];
  bool _loading = true, _checkingOut = false;
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    _load();
    _sub = RefreshNotifier().stream.listen((s) { if (s == 'all' || s == 'carrito') _load(); });
  }

  @override
  void dispose() { _sub?.cancel(); super.dispose(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    final uid = await _auth.obtenerIdUsuario();
    if (uid == null) { setState(() => _loading = false); return; }
    try {
      final data = await _carrito.listarDetalles(uid);
      setState(() { _items = data; _loading = false; });
    } catch (_) { setState(() => _loading = false); }
  }

  double get _total => _items.fold(0.0, (s, i) => s + ((i['producto']?['precio'] ?? 0) as num).toDouble());

  Future<void> _remove(int id) async {
    try { await _carrito.eliminarItem(id); _load(); RefreshNotifier().refreshAll(); } catch (_) {}
  }

  Future<void> _checkout() async {
    if (_items.isEmpty) return;
    setState(() => _checkingOut = true);
    final uid = await _auth.obtenerIdUsuario();
    if (uid == null) return;
    try {
      await _renta.crearRenta({'usuarioId': uid, 'detalles': _items.map((i) => {'productoId': i['producto']['id'], 'precioUnitario': i['producto']['precio'], 'fechaEntregaEsperada': i['fechaFinal'] ?? i['fechaInicio'], 'comentarios': ''}).toList()});
      for (final i in _items) { await _carrito.eliminarItem(i['id']); }
      if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Renta confirmada!'), backgroundColor: Colors.green)); RefreshNotifier().refreshAll(); _load(); }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
    setState(() => _checkingOut = false);
  }

  @override
  Widget build(BuildContext context) {
    final primary = Color(AppConfig.primaryColor);
    return Scaffold(
      appBar: AppBar(title: const Text('Carrito')),
      body: _loading ? const Center(child: CircularProgressIndicator()) : _items.isEmpty
          ? const Center(child: Text('Carrito vacio', style: TextStyle(color: Colors.grey, fontSize: 15)))
          : Column(children: [
              Expanded(child: RefreshIndicator(onRefresh: _load, child: ListView.builder(padding: const EdgeInsets.all(12), itemCount: _items.length, itemBuilder: (_, i) {
                final item = _items[i];
                final p = item['producto'];
                return Card(margin: const EdgeInsets.only(bottom: 8), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
                  child: Padding(padding: const EdgeInsets.all(12), child: Row(children: [
                    ClipRRect(borderRadius: BorderRadius.circular(8), child: Container(width: 56, height: 56, color: Color(AppConfig.bgColor), child: Image.network('${AppConfig.apiBaseUrl}${p?['imagenUrl'] ?? ''}', fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.image, color: Colors.grey, size: 30)))),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(p?['nombre'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      const SizedBox(height: 2),
                      Text('\$${p?['precio']}/dia', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: primary)),
                    ])),
                    IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20), onPressed: () => _remove(item['id'])),
                  ])),
                );
              }))),
              Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))]),
                child: SafeArea(child: Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), Text('\$${_total.toStringAsFixed(2)}', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primary))]),
                  const SizedBox(height: 12),
                  SizedBox(width: double.infinity, height: 50, child: FilledButton(onPressed: _checkingOut ? null : _checkout, style: FilledButton.styleFrom(backgroundColor: primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: _checkingOut ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Confirmar Renta', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)))),
                ])),
              ),
            ]),
    );
  }
}
