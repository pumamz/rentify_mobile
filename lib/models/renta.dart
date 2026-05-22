class Renta {
  final int id;
  final double total;
  final String fechaRenta;
  final List<DetalleRenta> detalles;

  Renta({required this.id, required this.total, required this.fechaRenta, required this.detalles});

  factory Renta.fromJson(Map<String, dynamic> json) {
    return Renta(
      id: json['id'],
      total: (json['total'] ?? 0).toDouble(),
      fechaRenta: json['fechaRenta'] ?? '',
      detalles: (json['detalles'] as List?)
          ?.map((d) => DetalleRenta.fromJson(d))
          .toList() ?? [],
    );
  }
}

class DetalleRenta {
  final int id;
  final String productoNombre;
  final double precioUnitario;
  final String estadoItem;
  final String? fechaEntregaReal;
  final String? comentarios;

  DetalleRenta({
    required this.id,
    required this.productoNombre,
    required this.precioUnitario,
    required this.estadoItem,
    this.fechaEntregaReal,
    this.comentarios,
  });

  factory DetalleRenta.fromJson(Map<String, dynamic> json) {
    return DetalleRenta(
      id: json['id'],
      productoNombre: json['producto']?['nombre'] ?? 'Producto',
      precioUnitario: (json['precioUnitario'] ?? 0).toDouble(),
      estadoItem: json['estadoItem'] ?? 'rentado',
      fechaEntregaReal: json['fechaEntregaReal'],
      comentarios: json['comentarios'],
    );
  }
}
