import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CarritoScreen extends StatefulWidget {
  const CarritoScreen({super.key});

  @override
  State<CarritoScreen> createState() => _CarritoScreenState();
}

class _CarritoScreenState extends State<CarritoScreen> {
  final String serverIp = "localhost"; 
  bool _isLoading = true;
  bool _isProcessingCheckout = false;
  
  List<dynamic> _detalles = [];
  double _totalCarrito = 0.0;

  @override
  void initState() {
    super.initState();
    _cargarCarrito();
  }

  // Obtener el carrito
  Future<void> _cargarCarrito() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final int? usuarioId = prefs.getInt('usuario_id');

    if (usuarioId == null) {
      setState(() => _isLoading = false);
      return;
    }

    final url = Uri.parse("http://$serverIp:8080/api/detalles-carrito/carrito/$usuarioId");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        
        setState(() {
          _detalles = data;
          if (_detalles.isNotEmpty && _detalles[0]['carrito'] != null) {
            _totalCarrito = (_detalles[0]['carrito']['total'] ?? 0).toDouble();
          } else {
            _totalCarrito = 0.0;
          }
        });
      }
    } catch (e) {
      print("Error cargando carrito: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al cargar el carrito: $e")),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Eliminar producto del carrito personal
  Future<void> _eliminarDelCarrito(int idDetalleCarrito) async {
    final url = Uri.parse("http://$serverIp:8080/api/detalles-carrito/$idDetalleCarrito");

    try {
      final response = await http.delete(url);
      
      if (response.statusCode == 200 || response.statusCode == 204) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Producto eliminado del carrito"), backgroundColor: Colors.orange),
        );
        _cargarCarrito(); // Recarga la lista y el total
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al eliminar: ${response.statusCode}")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error de conexión: $e")),
      );
    }
  }

  // Procesar el pago
  Future<void> _procesarCheckout() async {
    if (_detalles.isEmpty) return;
    
    setState(() => _isProcessingCheckout = true);
    final prefs = await SharedPreferences.getInstance();
    final int? usuarioId = prefs.getInt('usuario_id');

    final urlRentas = Uri.parse("http://$serverIp:8080/api/rentas");

    final List<Map<String, dynamic>> detallesRenta = _detalles.map((item) {
      return {
        "producto": {"id": item['producto']['id']},
        "fechaInicio": item['fechaInicio'],
        "fechaFin": item['fechaFinal'],
        "precioUnitario": item['producto']['precio'],
        "estadoItem": "rentado"
      };
    }).toList();

    final bodyRenta = jsonEncode({
      "usuario": {"id": usuarioId},
      "detalles": detallesRenta
    });

    try {
      final response = await http.post(
        urlRentas,
        headers: {"Content-Type": "application/json"},
        body: bodyRenta,
      );

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("¡Renta confirmada con éxito!", style: TextStyle(color: Colors.white)), 
            backgroundColor: Colors.green
          ),
        );
        
        Navigator.pop(context, true); 
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error al procesar la renta"), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error de conexión: $e")));
    } finally {
      if (mounted) setState(() => _isProcessingCheckout = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color rentifyPrimary = Color(0xFF6366F1);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mi Carrito"),
        backgroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: rentifyPrimary))
          : _detalles.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
                      SizedBox(height: 20),
                      Text("Tu carrito está vacío", style: TextStyle(fontSize: 18, color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount: _detalles.length,
                  itemBuilder: (context, index) {
                    final item = _detalles[index];
                    final producto = item['producto'];
                    
                    String imagePath = producto['imagenUrl'] ?? '';
                    if (!imagePath.startsWith('/')) imagePath = '/$imagePath';
                    final fullImageUrl = "http://$serverIp:8080$imagePath";

                    final fechaInicio = item['fechaInicio'].toString().split('T')[0];
                    final fechaFinal = item['fechaFinal'].toString().split('T')[0];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 15),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: [
                            Image.network(
                              fullImageUrl, 
                              width: 80, 
                              height: 80, 
                              fit: BoxFit.contain,
                              errorBuilder: (c, e, s) => const Icon(Icons.image, size: 50, color: Colors.grey)
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(producto['nombre'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  const SizedBox(height: 5),
                                  Text("\$${producto['precio']} / día", style: const TextStyle(color: rentifyPrimary, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 5),
                                  Text("Del $fechaInicio al $fechaFinal", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () {
                                _eliminarDelCarrito(item['id']);
                              },
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
      bottomNavigationBar: _detalles.isEmpty || _isLoading ? null : Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Total a Pagar:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text("\$${_totalCarrito.toStringAsFixed(2)}", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: rentifyPrimary)),
                ],
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: rentifyPrimary, foregroundColor: Colors.white),
                  onPressed: _isProcessingCheckout ? null : _procesarCheckout,
                  child: _isProcessingCheckout 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : const Text("Confirmar Renta", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}