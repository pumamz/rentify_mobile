import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../services/categoria_service.dart';
import '../services/auth_service.dart';
import '../models/categoria.dart';
import '../config/app_config.dart';

class RegistroProductoScreen extends StatefulWidget {
  const RegistroProductoScreen({super.key});
  @override
  State<RegistroProductoScreen> createState() => _RegistroProductoScreenState();
}

class _RegistroProductoScreenState extends State<RegistroProductoScreen> {
  final _form = GlobalKey<FormState>();
  final _api = ApiService();
  final _cat = CategoriaService();
  final _auth = AuthService();
  final _picker = ImagePicker();
  final _nombreCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _precioCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  final _stockMaxCtrl = TextEditingController();

  List<Categoria> _categorias = [];
  int? _catId;
  List<File> _imagenes = [];
  bool _loading = true, _guardando = false;

  @override
  void initState() { super.initState(); _loadCats(); }

  Future<void> _loadCats() async {
    try { final c = await _cat.listarCategorias(size: 50); setState(() { _categorias = c; _loading = false; }); } catch (_) { setState(() => _loading = false); }
  }

  Future<void> _pick() async {
    final files = await _picker.pickMultiImage(imageQuality: 80);
    if (files.isNotEmpty) setState(() => _imagenes = files.map((f) => File(f.path)).toList());
  }

  Future<void> _publicar() async {
    if (!_form.currentState!.validate() || _catId == null) return;
    final uid = await _auth.obtenerIdUsuario();
    if (uid == null) return;
    setState(() => _guardando = true);
    try {
      await _api.crearProducto({'nombre': _nombreCtrl.text.trim(), 'descripcion': _descCtrl.text.trim(), 'precio': _precioCtrl.text, 'stockActual': _stockCtrl.text, 'stockMaximo': _stockMaxCtrl.text, 'categoriaId': _catId.toString(), 'propietarioId': uid.toString()}, _imagenes.isNotEmpty ? _imagenes : null);
      if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Publicado!'), backgroundColor: Colors.green)); Navigator.pop(context, true); }
    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red)); }
    setState(() => _guardando = false);
  }

  @override
  Widget build(BuildContext context) {
    final primary = Color(AppConfig.primaryColor);
    return Scaffold(
      appBar: AppBar(title: const Text('Publicar Articulo')),
      body: _loading ? const Center(child: CircularProgressIndicator()) : SingleChildScrollView(padding: const EdgeInsets.all(16), child: Form(key: _form, child: Column(children: [
        TextFormField(controller: _nombreCtrl, decoration: InputDecoration(labelText: 'Nombre', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), validator: (v) => v == null || v.trim().isEmpty ? 'Requerido' : null),
        const SizedBox(height: 12),
        TextFormField(controller: _descCtrl, maxLines: 2, decoration: InputDecoration(labelText: 'Descripcion', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), validator: (v) => v == null || v.trim().isEmpty ? 'Requerido' : null),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: TextFormField(controller: _precioCtrl, decoration: InputDecoration(labelText: 'Precio/dia', prefixText: '\$ ', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), keyboardType: TextInputType.number, validator: (v) => v == null || double.tryParse(v) == null ? 'Invalido' : null)),
          const SizedBox(width: 12),
          Expanded(child: TextFormField(controller: _stockCtrl, decoration: InputDecoration(labelText: 'Stock', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), keyboardType: TextInputType.number)),
        ]),
        const SizedBox(height: 12),
        DropdownButtonFormField<int>(value: _catId, decoration: InputDecoration(labelText: 'Categoria', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), items: _categorias.map((c) => DropdownMenuItem(value: c.id, child: Text(c.nombre))).toList(), onChanged: (v) => setState(() => _catId = v), validator: (v) => v == null ? 'Requerido' : null),
        const SizedBox(height: 16),
        InkWell(onTap: _pick, child: Container(width: double.infinity, padding: const EdgeInsets.all(20), decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)), child: Column(children: [Icon(Icons.add_photo_alternate, size: 36, color: Colors.grey.shade400), const SizedBox(height: 6), Text(_imagenes.isEmpty ? 'Toca para fotos' : '${_imagenes.length} foto(s)', style: TextStyle(color: Colors.grey.shade500))]))),
        if (_imagenes.isNotEmpty) SizedBox(height: 100, child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: _imagenes.length, itemBuilder: (_, i) => Padding(padding: const EdgeInsets.only(right: 6, top: 8), child: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(_imagenes[i], width: 90, height: 90, fit: BoxFit.cover))))),
        const SizedBox(height: 24),
        SizedBox(width: double.infinity, height: 50, child: FilledButton(onPressed: _guardando ? null : _publicar, style: FilledButton.styleFrom(backgroundColor: primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: _guardando ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Publicar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)))),
      ]))),
    );
  }

  @override
  void dispose() {
    _nombreCtrl.dispose(); _descCtrl.dispose(); _precioCtrl.dispose(); _stockCtrl.dispose(); _stockMaxCtrl.dispose();
    super.dispose();
  }
}
