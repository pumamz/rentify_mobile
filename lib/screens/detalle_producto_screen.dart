import '../services/carrito_service.dart';
import '../services/auth_service.dart';
import '../services/refresh_notifier.dart';
import 'package:flutter/material.dart';
import '../models/producto.dart';
import '../config/app_config.dart';
import '../services/http_client_service.dart';

class DetalleProductoScreen extends StatefulWidget {
  final Producto producto;
  const DetalleProductoScreen({super.key, required this.producto});

  @override
  State<DetalleProductoScreen> createState() => _DetalleProductoScreenState();
}

class _DetalleProductoScreenState extends State<DetalleProductoScreen> {
  DateTimeRange? fechasRenta;
  bool cargando = false;
  String mensaje = '';
  final _carritoService = CarritoService();
  final _authService = AuthService();

  String getImagenUrl(String? ruta) {
    if (ruta == null || ruta.isEmpty) return 'https://placehold.co/400x400/6366F1/FFFFFF?text=Rentify';
    if (ruta.startsWith('http')) return ruta;
    return '${AppConfig.apiBaseUrl}$ruta';
  }

  int diasRenta() {
    if (fechasRenta == null) return 0;
    final diff = fechasRenta!.end.difference(fechasRenta!.start).inDays;
    return diff < 1 ? 1 : diff;
  }

  Future<void> _agregarAlCarrito() async {
    if (widget.producto.stockActual <= 0) {
      setState(() => mensaje = 'Producto agotado.');
      return;
    }
    if (fechasRenta == null) {
      setState(() => mensaje = 'Selecciona fechas de inicio y fin.');
      return;
    }

    final usuarioId = await _authService.obtenerIdUsuario();
    if (usuarioId == null) {
      setState(() => mensaje = 'Inicia sesion para agregar al carrito.');
      return;
    }

    setState(() { cargando = true; mensaje = 'Agregando...'; });

    try {
      await _carritoService.agregarAlCarrito(
        usuarioId,
        widget.producto.id,
        fechasRenta!.start.toIso8601String(),
        fechasRenta!.end.toIso8601String(),
      );
      if (mounted) {
        setState(() { cargando = false; mensaje = 'Agregado al carrito!'; });
        RefreshNotifier().refreshAll();
        Navigator.pop(context);
      }
    } on HttpException catch (e) {
      if (mounted) setState(() { cargando = false; mensaje = e.message; });
    } catch (e) {
      if (mounted) setState(() { cargando = false; mensaje = 'Error de conexion'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final sinStock = widget.producto.stockActual <= 0;
    final primary = Color(AppConfig.primaryColor);

    return Scaffold(
      appBar: AppBar(title: Text(widget.producto.nombre)),
      body: SingleChildScrollView(
        child: Column(children: [
          Container(
            height: 250, width: double.infinity, color: Color(AppConfig.bgColor),
            child: Image.network(getImagenUrl(widget.producto.imagenUrl), fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 80, color: Colors.grey)),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.producto.nombre, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('\$${widget.producto.precio.toStringAsFixed(0)} / dia',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: primary)),
              const SizedBox(height: 16),
              Text(widget.producto.descripcion, style: TextStyle(color: Colors.grey[700], fontSize: 15)),
              const SizedBox(height: 24),
              if (fechasRenta != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                  child: Row(children: [
                    const Icon(Icons.calendar_today, color: Colors.green),
                    const SizedBox(width: 10),
                    Expanded(child: Text(
                      '${fechasRenta!.start.toString().split(' ')[0]} - ${fechasRenta!.end.toString().split(' ')[0]} (${diasRenta()} dias)',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                    )),
                  ]),
                ),
                const SizedBox(height: 8),
                Text('\$ ${(diasRenta() * widget.producto.precio).toStringAsFixed(0)} total estimado',
                    style: TextStyle(fontSize: 16, color: primary, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
              ],
              SizedBox(width: double.infinity, child: ElevatedButton.icon(
                onPressed: _seleccionarFechas,
                icon: const Icon(Icons.date_range),
                label: Text(fechasRenta == null ? 'Seleccionar Fechas' : 'Cambiar Fechas'),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
              )),
              const SizedBox(height: 12),
              if (mensaje.isNotEmpty)
                Padding(padding: const EdgeInsets.only(bottom: 8),
                  child: Text(mensaje, style: TextStyle(color: mensaje.contains('Error') || mensaje.contains('agotado') ? Colors.red : primary))),
              SizedBox(width: double.infinity, child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: sinStock ? Colors.grey : primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: (fechasRenta == null || sinStock || cargando) ? null : _agregarAlCarrito,
                child: Text(sinStock ? 'Agotado' : cargando ? 'Agregando...' : 'Agregar al Carrito',
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              )),
            ]),
          ),
        ]),
      ),
    );
  }

  Future<void> _seleccionarFechas() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Selecciona periodo de renta',
    );
    if (picked != null) setState(() => fechasRenta = picked);
  }
}
