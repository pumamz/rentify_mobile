class Producto {
  final int id;
  final String nombre;
  final String descripcion;
  final double precio;
  final int stockActual;
  final String imagenUrl;

  Producto({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.stockActual,
    required this.imagenUrl,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      precio: (json['precio'] as num).toDouble(),
      stockActual: json['stockActual'],
      imagenUrl: json['imagenUrl'] ?? '',
    );
  }
}