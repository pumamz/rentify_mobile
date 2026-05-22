import 'package:flutter/material.dart';
import '../models/producto.dart';
import '../config/app_config.dart';
import '../screens/detalle_producto_screen.dart';

class ProductoCard extends StatelessWidget {
  final Producto producto;
  final VoidCallback onRefresh;
  const ProductoCard({super.key, required this.producto, required this.onRefresh});

  String getImagenUrl(String? ruta) {
    if (ruta == null || ruta.isEmpty) return 'https://placehold.co/400x300/6366F1/FFFFFF?text=${producto.nombre}';
    if (ruta.startsWith('http')) return ruta;
    return '${AppConfig.apiBaseUrl}$ruta';
  }

  @override
  Widget build(BuildContext context) {
    final primary = Color(AppConfig.primaryColor);
    final accent = Color(AppConfig.accentColor);

    return Card(
      margin: const EdgeInsets.all(10),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Stack(children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: Container(height: 180, width: double.infinity, color: Colors.white,
              child: Image.network(getImagenUrl(producto.imagenUrl), fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey))),
            ),
          ),
          Positioned(top: 10, right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: producto.stockActual > 0 ? accent : Colors.red,
                borderRadius: BorderRadius.circular(20)),
              child: Text(producto.stockActual > 0 ? 'Disp (${producto.stockActual})' : 'Agotado',
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ),
        ]),
        Padding(
          padding: const EdgeInsets.all(15),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(producto.nombre, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(producto.descripcion, style: TextStyle(color: Colors.grey[600], fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 14),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('\$${producto.precio.toStringAsFixed(0)} / dia',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: primary)),
              ElevatedButton(
                onPressed: () async {
                  await Navigator.push(context, MaterialPageRoute(
                    builder: (_) => DetalleProductoScreen(producto: producto)));
                  onRefresh();
                },
                style: ElevatedButton.styleFrom(backgroundColor: primary, foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                child: const Text('Ver Detalles'),
              ),
            ]),
          ]),
        ),
      ]),
    );
  }
}
