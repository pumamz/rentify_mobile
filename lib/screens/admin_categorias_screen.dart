import 'package:flutter/material.dart';
import '../models/categoria.dart';
import '../services/categoria_service.dart';

class AdminCategoriasScreen extends StatefulWidget {
  const AdminCategoriasScreen({super.key});
  @override
  State<AdminCategoriasScreen> createState() => _AdminCategoriasScreenState();
}

class _AdminCategoriasScreenState extends State<AdminCategoriasScreen> {
  final _catService = CategoriaService();
  List<Categoria> _categorias = [];
  bool _isLoading = true;
  final _nombreCtrl = TextEditingController();

  @override
  void initState() { super.initState(); _cargar(); }

  Future<void> _cargar() async {
    setState(() => _isLoading = true);
    try {
      final cats = await _catService.listarCategorias(size: 50);
      setState(() { _categorias = cats; _isLoading = false; });
    } catch (_) { setState(() => _isLoading = false); }
  }

  Future<void> _crear() async {
    final nombre = _nombreCtrl.text.trim();
    if (nombre.isEmpty) return;
    try {
      await _catService.crearCategoria(nombre);
      _nombreCtrl.clear();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Categoria creada!'), backgroundColor: Colors.green));
      _cargar();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Categorias')),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            Expanded(child: TextField(controller: _nombreCtrl, decoration: const InputDecoration(hintText: 'Nueva categoria', border: OutlineInputBorder()))),
            const SizedBox(width: 8),
            ElevatedButton(onPressed: _crear, child: const Text('Crear')),
          ]),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: _categorias.length,
                  itemBuilder: (_, i) => ListTile(title: Text(_categorias[i].nombre), leading: CircleAvatar(child: Text('${_categorias[i].id}'))),
                ),
        ),
      ]),
    );
  }
}
