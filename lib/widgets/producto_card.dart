import 'package:flutter/material.dart';
import '../models/producto.dart';
import '../screens/detalle_producto_screen.dart';

class ProductoCard extends StatelessWidget {
  final Producto producto;
  final VoidCallback onRefresh; 

  // Eliminamos el 'onDelete' de aquí
  const ProductoCard({
    super.key, 
    required this.producto, 
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    const Color rentifyPrimary = Color(0xFF6366F1);
    const Color rentifySecondary = Color(0xFF10B981);
    final String serverIp = "localhost";

    String imagePath = producto.imagenUrl;
    if (!imagePath.startsWith('/')) imagePath = '/$imagePath';
    final String fullImageUrl = "http://$serverIp:8080$imagePath";

    return Card(
      margin: const EdgeInsets.all(10),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                child: Container(
                  height: 180,
                  width: double.infinity,
                  color: Colors.white,
                  child: Image.network(
                    fullImageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.broken_image, size: 50, color: Colors.grey),
                          SizedBox(height: 8),
                          Text("Error al cargar", style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: producto.stockActual > 0 ? rentifySecondary : Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    producto.stockActual > 0 ? "Disponible (${producto.stockActual})" : "Agotado",
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Aquí quitamos el Row que tenía el icono del basurero y dejamos solo el texto
                Text(
                  producto.nombre,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Text(
                  producto.descripcion,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "\$${producto.precio} / día",
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: rentifyPrimary),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => DetalleProductoScreen(producto: producto)),
                        );
                        onRefresh(); 
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: rentifyPrimary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text("Ver Detalles"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}