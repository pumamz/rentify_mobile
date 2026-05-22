import 'package:flutter/material.dart';
import 'config/app_config.dart';
import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/mis_rentas_screen.dart';
import 'screens/registro_producto_screen.dart';
import 'screens/admin_productos_screen.dart';
import 'screens/admin_categorias_screen.dart';
import 'screens/carrito_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RentifyApp());
}

class RentifyApp extends StatelessWidget {
  const RentifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rentify',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Color(AppConfig.primaryColor),
        brightness: Brightness.light,
        fontFamily: 'Roboto',
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});
  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final _authService = AuthService();
  bool _isLoggedIn = false;
  bool _isAdmin = false;
  bool _checked = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final logged = await _authService.isLoggedIn();
    final admin = await _authService.isAdmin();
    setState(() { _isLoggedIn = logged; _isAdmin = admin; _checked = true; });
  }

  void _onAuthChanged() => _checkAuth();

  @override
  Widget build(BuildContext context) {
    if (!_checked) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!_isLoggedIn) {
      return LoginScreen(onLoginSuccess: _onAuthChanged);
    }
    return MainShell(isAdmin: _isAdmin, onLogout: () { _authService.logout(); _onAuthChanged(); });
  }
}

class MainShell extends StatefulWidget {
  final bool isAdmin;
  final VoidCallback onLogout;
  const MainShell({super.key, required this.isAdmin, required this.onLogout});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final tabs = <Widget>[
      const HomeScreen(),
      const MisRentasScreen(),
      const RegistroProductoScreen(),
      const CarritoScreen(),
    ];

    final adminTabs = <String>['Catalogo', 'Admin Prod', 'Admin Cat', 'Publicar'];

    if (widget.isAdmin) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Rentify Admin'),
          actions: [IconButton(icon: const Icon(Icons.logout), onPressed: widget.onLogout)],
        ),
        body: IndexedStack(index: _currentIndex, children: [
          const HomeScreen(),
          const AdminProductosScreen(),
          const AdminCategoriasScreen(),
          const RegistroProductoScreen(),
        ]),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (i) => setState(() => _currentIndex = i),
          destinations: adminTabs.map((t) => NavigationDestination(icon: const Icon(Icons.build), label: t)).toList(),
        ),
      );
    }

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Catalogo'),
          NavigationDestination(icon: Icon(Icons.receipt_long), label: 'Mis Rentas'),
          NavigationDestination(icon: Icon(Icons.add_circle_outline), label: 'Publicar'),
          NavigationDestination(icon: Icon(Icons.shopping_cart), label: 'Carrito'),
        ],
      ),
    );
  }
}
