import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/categoria.dart';
import '../config/app_config.dart';
import '../services/api_service.dart';
import '../services/categoria_service.dart';
import '../services/auth_service.dart';

class RegistroProductoScreen extends StatefulWidget {
  const RegistroProductoScreen({super.key});
  @override
  State<RegistroProductoScreen> createState() => _RegistroProductoScreenState();
}

class _RegistroProductoScreenState extends State<RegistroProductoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();
  final _catService = CategoriaService();
  final _authService = AuthService();
  final _picker = ImagePicker();

  List<Categoria> _categorias = [];
  List<File> _imagenes = [];
  bool _guardando = false;

  final _nombreCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _precioCtrl = TextEditingController(text: '0');
  final _stockActualCtrl = TextEditingController(text: '1');
  final _stockMaximoCtrl = TextEditingController(text: '1');
  int? _categoriaId;

  @override
  void initState() {
    super.initState();
    _cargarCategorias();
  }

  Future<void> _cargarCategorias() async {
    try {
      final cats = await _catService.listarCategorias();
      setState(() => _categorias = cats);
    } catch (_) {}
  }

  Future<void> _pickImagenes() async {
    final files = await _picker.pickMultiImage(imageQuality: 80);
    if (files.isNotEmpty) {
      setState(() => _imagenes = files.map((f) => File(f.path)).toList());
    }
  }

  Future<void> _publicar() async {
    if (!_formKey.currentState!.validate() || _categoriaId == null) return;

    final usuarioId = await _authService.obtenerIdUsuario();
    if (usuarioId == null) return;

    setState(() => _guardando = true);
    try {
      final fields = {
        'nombre': _nombreCtrl.text.trim(),
        'descripcion': _descCtrl.text.trim(),
        'precio': double.parse(_precioCtrl.text).toString(),
        'stockActual': _stockActualCtrl.text,
        'stockMaximo': _stockMaximoCtrl.text,
        'categoriaId': _categoriaId.toString(),
        'propietarioId': usuarioId.toString(),
      };

      if (_imagenes.isNotEmpty) {
        await _apiService.crearProducto(fields, _imagenes);
      } else {
        await _apiService.crearProducto(fields, null);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Producto publicado!'), backgroundColor: Colors.green));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
    setState(() => _guardando = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Publicar Articulo')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(key: _formKey, child: Column(children: [
          TextFormField(controller: _nombreCtrl, decoration: const InputDecoration(labelText: 'Nombre', border: OutlineInputBorder()),
            validator: (v) => v == null || v.trim().isEmpty ? 'Requerido' : null),
          const SizedBox(height: 12),
          TextFormField(controller: _descCtrl, decoration: const InputDecoration(labelText: 'Descripcion', border: OutlineInputBorder()), maxLines: 2,
            validator: (v) => v == null || v.trim().isEmpty ? 'Requerido' : null),
          const SizedBox(height: 12),
          TextFormField(controller: _precioCtrl, decoration: const InputDecoration(labelText: 'Precio por dia', border: OutlineInputBorder(), prefixText: '\$ '),
            keyboardType: TextInputType.number, validator: (v) => v == null || double.tryParse(v) == null ? 'Invalido' : null),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: TextFormField(controller: _stockActualCtrl, decoration: const InputDecoration(labelText: 'Stock Actual', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
            const SizedBox(width: 12),
            Expanded(child: TextFormField(controller: _stockMaximoCtrl, decoration: const InputDecoration(labelText: 'Stock Maximo', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
          ]),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            value: _categoriaId,
            decoration: const InputDecoration(labelText: 'Categoria', border: OutlineInputBorder()),
            items: _categorias.map((c) => DropdownMenuItem(value: c.id, child: Text(c.nombre))).toList(),
            onChanged: (v) => setState(() => _categoriaId = v),
            validator: (v) => v == null ? 'Selecciona una categoria' : null,
          ),
          const SizedBox(height: 16),
          InkWell(onTap: _pickImagenes, child: Container(
            width: double.infinity, padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(12), color: Color(AppConfig.bgColor)),
            child: Column(children: [
              const Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey),
              const SizedBox(height: 8),
              Text(_imagenes.isEmpty ? 'Toca para seleccionar imagenes' : '${_imagenes.length} imagen(es) seleccionada(s)',
                  style: const TextStyle(color: Colors.grey)),
            ]),
          )),
          if (_imagenes.isNotEmpty) ...[
            const SizedBox(height: 8),
            SizedBox(height: 80, child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: _imagenes.length, itemBuilder: (_, i) {
              return Padding(padding: const EdgeInsets.only(right: 8), child: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(_imagenes[i], width: 80, height: 80, fit: BoxFit.cover)));
            })),
          ],
          const SizedBox(height: 24),
          SizedBox(width: double.infinity, height: 48,
            child: ElevatedButton(
              onPressed: _guardando ? null : _publicar,
              style: ElevatedButton.styleFrom(backgroundColor: Color(AppConfig.primaryColor), foregroundColor: Colors.white),
              child: _guardando ? const CircularProgressIndicator(color: Colors.white) : const Text('Publicar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            )),
        ])),
      ),
    );
  }
}
