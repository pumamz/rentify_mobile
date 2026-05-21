import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // Para obtener el ID del usuario
import '../models/producto.dart';

class DetalleProductoScreen extends StatefulWidget {
  final Producto producto;
  const DetalleProductoScreen({super.key, required this.producto});

  @override
  State<DetalleProductoScreen> createState() => _DetalleProductoScreenState();
}

class _DetalleProductoScreenState extends State<DetalleProductoScreen> {
  DateTimeRange? fechasRenta;
  final String baseUrl = "https://api-rentify-production.up.railway.app"; 

  Future<void> _seleccionarFechas() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Selecciona periodo de renta',
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF6366F1)),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => fechasRenta = picked);
  }

  // NUEVA FUNCIÓN: Agregar al Carrito (Sincronizado con Web/Angular)
  Future<void> _agregarAlCarrito() async {
    final url = Uri.parse("$baseUrl/api/v1/detalles-carrito/agregar");
    
    // 1. Obtenemos el ID del usuario que guardamos en el Login
    final prefs = await SharedPreferences.getInstance();
    final int? usuarioId = prefs.getInt('usuario_id');

    if (usuarioId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: No se encontró sesión activa")),
      );
      return;
    }

    // 2. Armamos el JSON exactamente como lo espera tu DetalleCarritoController
    final body = jsonEncode({
      "fechaInicio": fechasRenta!.start.toIso8601String(),
      "fechaFinal": fechasRenta!.end.toIso8601String(),
      "producto": {
        "id": widget.producto.id
      },
      "carrito": {
        "id": usuarioId // Tu backend usa esto como ID de usuario para buscar el carrito
      }
    });

    try {
      final response = await http.post(
        url, 
        headers: {"Content-Type": "application/json"}, 
        body: body
      );

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("¡Producto añadido al carrito! Revisa tu web de Angular."),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); 
      } else {
        print("Error del server: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al añadir al carrito: ${response.statusCode}")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error de conexión: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color rentifyPrimary = Color(0xFF6366F1);
    bool sinStock = widget.producto.stockActual <= 0;

    String imagePath = widget.producto.imagenUrl;
    if (!imagePath.startsWith('/')) imagePath = '/$imagePath';
    final String fullImageUrl = "$baseUrl$imagePath";

    return Scaffold(
      appBar: AppBar(title: Text(widget.producto.nombre)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              height: 250,
              width: double.infinity,
              child: Image.network(
                fullImageUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => 
                    const Icon(Icons.broken_image, size: 100, color: Colors.grey),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.producto.nombre, 
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text("\$${widget.producto.precio} / día", 
                      style: const TextStyle(fontSize: 22, color: rentifyPrimary, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 20),
                  Text(widget.producto.descripcion,
                      style: TextStyle(color: Colors.grey[700], fontSize: 16)),
                  const SizedBox(height: 30),
                  
                  if (fechasRenta != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.green),
                          const SizedBox(width: 10),
                          Text(
                            "Del ${fechasRenta!.start.toString().split(' ')[0]} al ${fechasRenta!.end.toString().split(' ')[0]}",
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  ElevatedButton.icon(
                    onPressed: sinStock ? null : _seleccionarFechas,
                    icon: const Icon(Icons.date_range),
                    label: Text(fechasRenta == null ? "Seleccionar Fechas" : "Cambiar Fechas"),
                    style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                  ),
                  const SizedBox(height: 15),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: sinStock ? Colors.grey : rentifyPrimary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      // Ahora llama a la función de agregar al carrito
                      onPressed: (fechasRenta == null || sinStock) ? null : _agregarAlCarrito,
                      child: Text(
                        sinStock ? "Producto Agotado" : "Agregar al Carrito", 
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}