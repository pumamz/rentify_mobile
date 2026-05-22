import 'package:flutter/material.dart';
import '../models/producto.dart';
import '../services/api_service.dart';

class AdminProductosScreen extends StatefulWidget {
  const AdminProductosScreen({super.key});
  @override
  State<AdminProductosScreen> createState() => _AdminProductosScreenState();
}

class _AdminProductosScreenState extends State<AdminProductosScreen> {
  final _apiService = ApiService();
  List<Producto> _productos = [];
  bool _isLoading = true;
  int? _editandoId;
  final _nombreCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _precioCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  final _stockMaxCtrl = TextEditingController();

  @override
  void initState() { super.initState(); _cargar(); }

  Future<void> _cargar() async {
    setState(() => _isLoading = true);
    try {
      final prods = await _apiService.getProductos(size: 200);
      setState(() { _productos = prods; _isLoading = false; });
    } catch (_) { setState(() => _isLoading = false); }
  }

  void _empezarEdicion(Producto p) {
    _editandoId = p.id;
    _nombreCtrl.text = p.nombre;
    _descCtrl.text = p.descripcion;
    _precioCtrl.text = p.precio.toString();
    _stockCtrl.text = p.stockActual.toString();
    _stockMaxCtrl.text = p.stockMaximo.toString();
    setState(() {});
  }

  Future<void> _guardar(int id) async {
    try {
      await _apiService.actualizarProducto(id, {
        'nombre': _nombreCtrl.text,
        'descripcion': _descCtrl.text,
        'precio': double.parse(_precioCtrl.text),
        'stockActual': int.parse(_stockCtrl.text),
        'stockMaximo': int.parse(_stockMaxCtrl.text),
        'categoriaId': 1,
        'propietarioId': 1,
      });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Actualizado!'), backgroundColor: Colors.green));
      setState(() => _editandoId = null);
      _cargar();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Productos')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _productos.length,
              itemBuilder: (_, i) {
                final p = _productos[i];
                final editando = _editandoId == p.id;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: editando
                        ? Column(children: [
                            TextField(controller: _nombreCtrl, decoration: const InputDecoration(labelText: 'Nombre')),
                            TextField(controller: _precioCtrl, decoration: const InputDecoration(labelText: 'Precio'), keyboardType: TextInputType.number),
                            Row(children: [
                              Expanded(child: TextField(controller: _stockCtrl, decoration: const InputDecoration(labelText: 'Stock'), keyboardType: TextInputType.number)),
                              const SizedBox(width: 8),
                              Expanded(child: TextField(controller: _stockMaxCtrl, decoration: const InputDecoration(labelText: 'Stock Max'), keyboardType: TextInputType.number)),
                            ]),
                            const SizedBox(height: 8),
                            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                              TextButton(onPressed: () => setState(() => _editandoId = null), child: const Text('Cancelar')),
                              const SizedBox(width: 8),
                              ElevatedButton(onPressed: () => _guardar(p.id), child: const Text('Guardar')),
                            ]),
                          ])
                        : Row(children: [
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(p.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text('\$${p.precio.toStringAsFixed(0)} | Stock: ${p.stockActual}/${p.stockMaximo}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                            ])),
                            IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _empezarEdicion(p)),
                          ]),
                  ),
                );
              },
            ),
    );
  }
}
