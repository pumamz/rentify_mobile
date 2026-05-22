import 'package:flutter/material.dart';
import '../models/producto.dart';
import '../models/categoria.dart';
import '../config/app_config.dart';
import '../services/api_service.dart';
import '../services/categoria_service.dart';
import '../widgets/producto_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _apiService = ApiService();
  final _catService = CategoriaService();
  List<Producto> _productos = [];
  List<Producto> _filtrados = [];
  List<Categoria> _categorias = [];
  bool _isLoading = true;
  String _search = '';
  String? _categoriaFiltro;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _isLoading = true);
    try {
      final cats = await _catService.listarCategorias();
      final prods = await _apiService.getProductos(size: 100);
      setState(() { _categorias = cats; _productos = prods; _isLoading = false; });
      _aplicarFiltros();
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  void _aplicarFiltros() {
    var result = List<Producto>.from(_productos);
    if (_search.isNotEmpty) {
      final term = _search.toLowerCase();
      result = result.where((p) => p.nombre.toLowerCase().contains(term) || p.descripcion.toLowerCase().contains(term)).toList();
    }
    if (_categoriaFiltro != null) {
      result = result.where((p) => p.nombre == _categoriaFiltro).toList();
    }
    setState(() => _filtrados = result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rentify'), centerTitle: true),
      body: Column(children: [
        Padding(padding: const EdgeInsets.all(12), child: Row(children: [
          Expanded(child: TextField(
            decoration: InputDecoration(hintText: 'Buscar herramienta...', prefixIcon: const Icon(Icons.search),
              filled: true, fillColor: Color(AppConfig.bgColor), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
            onChanged: (v) { _search = v; _aplicarFiltros(); },
          )),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(color: Color(AppConfig.bgColor), borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButton<String?>(
              value: _categoriaFiltro,
              hint: const Text('Todas'),
              underline: const SizedBox(),
              items: [const DropdownMenuItem(value: null, child: Text('Todas')), ..._categorias.map((c) => DropdownMenuItem(value: c.nombre, child: Text(c.nombre)))],
              onChanged: (v) { _categoriaFiltro = v; _aplicarFiltros(); },
            ),
          ),
        ])),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _cargar,
                  child: _filtrados.isEmpty
                      ? ListView(children: const [SizedBox(height: 120), Center(child: Text('Sin resultados', style: TextStyle(color: Colors.grey, fontSize: 16)))])
                      : ListView.builder(
                          itemCount: _filtrados.length,
                          itemBuilder: (_, i) => ProductoCard(producto: _filtrados[i], onRefresh: _cargar),
                        ),
                ),
        ),
      ]),
    );
  }
}
