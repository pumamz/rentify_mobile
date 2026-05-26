import 'dart:async';
import 'package:flutter/material.dart';
import 'config/app_config.dart';
import 'services/auth_service.dart';
import 'services/refresh_notifier.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/mis_rentas_screen.dart';
import 'screens/registro_producto_screen.dart';
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
        colorScheme: ColorScheme.fromSeed(seedColor: Color(AppConfig.primaryColor), brightness: Brightness.light),
        scaffoldBackgroundColor: Color(AppConfig.bgColor),
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
  final _auth = AuthService();
  bool _logged = false, _checked = false;
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    _check();
    _sub = RefreshNotifier().stream.listen((s) {
      if (s == 'logout' && mounted) _check();
    });
  }

  @override
  void dispose() { _sub?.cancel(); super.dispose(); }

  Future<void> _check() async {
    final ok = await _auth.isLoggedIn();
    if (!mounted) return;
    setState(() { _logged = ok; _checked = true; });
  }

  @override
  Widget build(BuildContext context) {
    if (!_checked) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (!_logged) return LoginScreen(onLoginSuccess: _check);
    return const MainShell();
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  void _switchTab(int i) {
    setState(() => _index = i);
    RefreshNotifier().refreshAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [HomeScreen(), MisRentasScreen(), RegistroProductoScreen(), CarritoScreen()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _switchTab,
        animationDuration: const Duration(milliseconds: 300),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Catalogo'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Mis Rentas'),
          NavigationDestination(icon: Icon(Icons.add_circle_outline), selectedIcon: Icon(Icons.add_circle), label: 'Publicar'),
          NavigationDestination(icon: Icon(Icons.shopping_cart_outlined), selectedIcon: Icon(Icons.shopping_cart), label: 'Carrito'),
        ],
      ),
    );
  }
}
