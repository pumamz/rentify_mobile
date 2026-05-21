import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../models/producto.dart';
import '../widgets/producto_card.dart';
import 'login_screen.dart';
import 'carrito_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Producto>> _productosFuture;

  @override
  void initState() {
    super.initState();
    _refreshProductos(); 
  }

  Future<void> _refreshProductos() async {
    setState(() {
      _productosFuture = _apiService.getProductos();
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color rentifyPrimary = Color(0xFF6366F1);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Catálogo Rentify", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined), 
            onPressed: () async {
              final cambios = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CarritoScreen()),
              );
              
              if (cambios == true) {
                _refreshProductos();
              }
            }
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () async {
              await AuthService().logout(); 
              if (!context.mounted) return;
              
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshProductos,
        color: rentifyPrimary,
        child: FutureBuilder<List<Producto>>(
          future: _productosFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return ListView(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.4,
                    child: Center(child: Text("Error: ${snapshot.error}")),
                  ),
                ],
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return ListView(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.4,
                    child: const Center(child: Text("No hay productos disponibles")),
                  ),
                ],
              );
            } else {
              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 80), 
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final producto = snapshot.data![index];
                  return ProductoCard(
                    producto: producto,
                    onRefresh: _refreshProductos, 
                  );
                },
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: rentifyPrimary,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          // Aquí navegarías a la pantalla de agregar producto en el futuro
        }, 
      ),
    );
  }
}