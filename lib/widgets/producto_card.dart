import 'package:flutter/material.dart';
import '../models/producto.dart';
import '../config/app_config.dart';
import '../screens/detalle_producto_screen.dart';

class ProductoCard extends StatelessWidget {
  final Producto producto;
  final VoidCallback onRefresh;
  const ProductoCard({super.key, required this.producto, required this.onRefresh});

  String getImagenUrl(String? ruta) {
    if (ruta == null || ruta.isEmpty) return 'https://placehold.co/400x300/E2E8F0/64748B?text=Sin+Imagen';
    if (ruta.startsWith('http')) return ruta;
    return '${AppConfig.apiBaseUrl}$ruta';
  }

  @override
  Widget build(BuildContext context) {
    final primary = Color(AppConfig.primaryColor);
    final disponible = producto.stockActual > 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: Colors.grey.shade200)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () async { await Navigator.push(context, MaterialPageRoute(builder: (_) => DetalleProductoScreen(producto: producto))); onRefresh(); },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            ClipRRect(borderRadius: BorderRadius.circular(10),
              child: Container(width: 90, height: 90, color: Color(AppConfig.bgColor),
                child: Image.network(getImagenUrl(producto.imagenUrl), fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Icon(Icons.image, color: Colors.grey.shade300, size: 40)))),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(producto.nombre, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              const SizedBox(height: 4),
              Text(producto.descripcion, style: TextStyle(color: Colors.grey.shade600, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 8),
              Row(children: [
                Text('\$${producto.precio.toStringAsFixed(0)}/dia', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: primary)),
                const Spacer(),
                Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: disponible ? Color(AppConfig.accentColor).withOpacity(0.1) : Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                  child: Text(disponible ? '${producto.stockActual} disp' : 'Agotado', style: TextStyle(color: disponible ? Color(AppConfig.accentColor) : Colors.red, fontSize: 12, fontWeight: FontWeight.w600))),
              ]),
            ])),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ]),
        ),
      ),
    );
  }
}
