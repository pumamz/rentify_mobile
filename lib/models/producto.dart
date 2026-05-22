class Producto {
  final int id;
  final String nombre;
  final String descripcion;
  final double precio;
  final int stockActual;
  final int stockMaximo;
  final String imagenUrl;

  Producto({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.stockActual,
    required this.stockMaximo,
    required this.imagenUrl,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
      precio: (json['precio'] as num?)?.toDouble() ?? 0,
      stockActual: json['stockActual'] ?? 0,
      stockMaximo: json['stockMaximo'] ?? 0,
      imagenUrl: json['imagenUrl'] ?? '',
    );
  }
}
