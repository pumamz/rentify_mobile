import 'package:flutter/material.dart';
import '../models/renta.dart';
import '../config/app_config.dart';
import '../services/renta_service.dart';
import '../services/refresh_notifier.dart';
import 'dart:async';

class MisRentasScreen extends StatefulWidget {
  const MisRentasScreen({super.key});
  @override
  State<MisRentasScreen> createState() => _MisRentasScreenState();
}

class _MisRentasScreenState extends State<MisRentasScreen> {
  final _renta = RentaService();
  List<Renta> _rentas = [];
  bool _loading = true;
  int? _devolviendo;
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    _load();
    _sub = RefreshNotifier().stream.listen((s) { if (s == 'all' || s == 'rentas') _load(); });
  }

  @override
  void dispose() { _sub?.cancel(); super.dispose(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try { final data = await _renta.listarRentas(size: 50); setState(() { _rentas = data; _loading = false; }); }
    catch (_) { setState(() => _loading = false); }
  }

  Color _badgeColor(String estado) {
    switch (estado) { case 'rentado': return Color(AppConfig.accentColor); case 'atrasado': return Color(AppConfig.errorColor); case 'devuelto': return Colors.grey; default: return Colors.grey; }
  }

  Future<void> _devolver(int id) async {
    setState(() => _devolviendo = id);
    try { await _renta.devolverProducto(id); if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Producto devuelto!'), backgroundColor: Colors.green)); RefreshNotifier().refreshAll(); } _load(); }
    catch (_) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al devolver'), backgroundColor: Colors.red)); }
    setState(() => _devolviendo = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis Rentas')),
      body: _loading ? const Center(child: CircularProgressIndicator()) : _rentas.isEmpty
          ? const Center(child: Text('No tienes rentas', style: TextStyle(color: Colors.grey, fontSize: 15)))
          : RefreshIndicator(onRefresh: _load, child: ListView.builder(padding: const EdgeInsets.all(12), itemCount: _rentas.length, itemBuilder: (_, i) {
              final r = _rentas[i];
              return Card(margin: const EdgeInsets.only(bottom: 10), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: Colors.grey.shade200)),
                child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Renta #${r.id}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)), Text('\$${r.total.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.w700, color: Color(AppConfig.primaryColor), fontSize: 16))]),
                  const SizedBox(height: 10),
                  ...r.detalles.map((d) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Row(children: [
                    Expanded(child: Text(d.productoNombre, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13))),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: _badgeColor(d.estadoItem), borderRadius: BorderRadius.circular(10)), child: Text(d.estadoItem, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600))),
                    if (d.estadoItem == 'rentado') ...[const SizedBox(width: 8), SizedBox(height: 32, child: ElevatedButton(onPressed: _devolviendo == d.id ? null : () => _devolver(d.id), style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 10), textStyle: const TextStyle(fontSize: 11)), child: _devolviendo == d.id ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Devolver')))],
                  ]))),
                ])),
              );
            })),
    );
  }
}
