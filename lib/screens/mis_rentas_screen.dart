import 'package:flutter/material.dart';
import '../models/renta.dart';
import '../config/app_config.dart';
import '../services/renta_service.dart';

class MisRentasScreen extends StatefulWidget {
  const MisRentasScreen({super.key});
  @override
  State<MisRentasScreen> createState() => _MisRentasScreenState();
}

class _MisRentasScreenState extends State<MisRentasScreen> {
  final _rentaService = RentaService();
  List<Renta> _rentas = [];
  bool _isLoading = true;
  int? _devolviendo;

  @override
  void initState() { super.initState(); _cargar(); }

  Future<void> _cargar() async {
    setState(() => _isLoading = true);
    try {
      final rentas = await _rentaService.listarRentas(size: 50);
      setState(() { _rentas = rentas; _isLoading = false; });
    } catch (_) { setState(() => _isLoading = false); }
  }

  Color _badgeColor(String estado) {
    switch (estado) {
      case 'rentado': return Color(AppConfig.accentColor);
      case 'atrasado': return Color(AppConfig.errorColor);
      case 'devuelto': return Colors.grey;
      default: return Colors.grey;
    }
  }

  Future<void> _devolver(int detalleId) async {
    setState(() => _devolviendo = detalleId);
    try {
      await _rentaService.devolverProducto(detalleId, nota: 'Devuelto por el cliente');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Producto devuelto!'), backgroundColor: Colors.green));
      _cargar();
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al devolver'), backgroundColor: Colors.red));
    }
    setState(() => _devolviendo = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis Rentas')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _rentas.isEmpty
              ? const Center(child: Text('No tienes rentas', style: TextStyle(color: Colors.grey, fontSize: 16)))
              : RefreshIndicator(
                  onRefresh: _cargar,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _rentas.length,
                    itemBuilder: (_, i) {
                      final renta = _rentas[i];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              Text('Renta #${renta.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text('\$${renta.total.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, color: Color(AppConfig.primaryColor))),
                            ]),
                            const Divider(),
                            ...renta.detalles.map((d) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(children: [
                                Expanded(child: Text(d.productoNombre, style: const TextStyle(fontWeight: FontWeight.w500))),
                                const SizedBox(width: 8),
                                Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(color: _badgeColor(d.estadoItem), borderRadius: BorderRadius.circular(12)),
                                  child: Text(d.estadoItem, style: const TextStyle(color: Colors.white, fontSize: 12))),
                                if (d.estadoItem == 'rentado') ...[
                                  const SizedBox(width: 8),
                                  SizedBox(height: 30, child: ElevatedButton(
                                    onPressed: _devolviendo == d.id ? null : () => _devolver(d.id),
                                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12)),
                                    child: _devolviendo == d.id ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Devolver', style: TextStyle(fontSize: 12)),
                                  )),
                                ],
                              ]),
                            )),
                          ]),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
