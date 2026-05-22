import 'package:flutter/material.dart';
import '../models/producto.dart';
import '../services/api_service.dart';
import '../services/categoria_service.dart';
import '../config/app_config.dart';
import '../widgets/producto_card.dart';
import '../services/auth_service.dart';
import '../services/refresh_notifier.dart';
import 'login_screen.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _api = ApiService(); final _cat = CategoriaService();
  List<Producto> _all = [], _filtered = [];
  List<String> _categorias = [];
  String _search = '', _catFiltro = '';
  bool _loading = true;
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    _load();
    _sub = RefreshNotifier().stream.listen((s) { if (s == 'all' || s == 'home') _load(); });
  }

  @override
  void dispose() { _sub?.cancel(); super.dispose(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final cats = await _cat.listarCategorias(size: 50);
      final prods = await _api.getProductos(size: 200);
      setState(() { _all = prods; _categorias = cats.map((c) => c.nombre).toList(); _loading = false; });
      _filter();
    } catch (_) { setState(() => _loading = false); }
  }

  void _filter() {
    var r = List<Producto>.from(_all);
    if (_search.isNotEmpty) { final t = _search.toLowerCase(); r = r.where((p) => p.nombre.toLowerCase().contains(t) || p.descripcion.toLowerCase().contains(t)).toList(); }
    if (_catFiltro.isNotEmpty) r = r.where((p) => p.categoriaNombre == _catFiltro).toList();
    setState(() => _filtered = r);
  }

  List<DropdownMenuItem<String>> _buildCatItems() {
    final items = <DropdownMenuItem<String>>[const DropdownMenuItem(value: '', child: Text('Todas', style: TextStyle(fontSize: 13)))];
    for (final c in _categorias) { items.add(DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13)))); }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rentify'), centerTitle: true,
        actions: [IconButton(icon: const Icon(Icons.logout), tooltip: 'Salir', onPressed: () async {
          await AuthService().logout();
          if (mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
        })]),
      body: Column(children: [
        Padding(padding: const EdgeInsets.fromLTRB(12, 8, 12, 4), child: Row(children: [
          Expanded(child: TextField(
            decoration: InputDecoration(hintText: 'Buscar...', prefixIcon: const Icon(Icons.search, size: 20),
              filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), isDense: true),
            onChanged: (v) { _search = v; _filter(); },
          )),
          const SizedBox(width: 8),
          SizedBox(width: 130, child: DropdownButtonFormField<String>(
            value: _catFiltro.isEmpty ? null : _catFiltro,
            decoration: InputDecoration(filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), isDense: true),
            hint: const Text('Todas', style: TextStyle(fontSize: 13)),
            items: _buildCatItems(),
            onChanged: (v) { _catFiltro = v ?? ''; _filter(); },
          )),
        ])),
        Expanded(child: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(onRefresh: _load,
                child: _filtered.isEmpty
                    ? ListView(children: const [SizedBox(height: 100), Center(child: Text('Sin resultados', style: TextStyle(color: Colors.grey, fontSize: 15)))])
                    : ListView.builder(padding: const EdgeInsets.all(8), itemCount: _filtered.length, itemBuilder: (_, i) => ProductoCard(producto: _filtered[i], onRefresh: _load)))),
      ]),
    );
  }
}
