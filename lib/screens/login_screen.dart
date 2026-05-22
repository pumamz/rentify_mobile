import 'package:flutter/material.dart';
import 'registro_screen.dart';
import '../services/auth_service.dart';
import '../config/app_config.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback? onLoginSuccess;
  const LoginScreen({super.key, this.onLoginSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _auth = AuthService();
  bool _loading = false;

  Future<void> _login() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    final r = await _auth.login(_userCtrl.text.trim(), _passCtrl.text);
    if (!mounted) return;
    setState(() => _loading = false);
    if (r['success'] == true) {
      widget.onLoginSuccess?.call();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(r['message'] ?? 'Error'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Color(AppConfig.primaryColor);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _form,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const SizedBox(height: 40),
                Container(width: 64, height: 64, decoration: BoxDecoration(color: primary.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                  child: Icon(Icons.construction, size: 32, color: primary)),
                const SizedBox(height: 16),
                const Text('Rentify', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('Renta herramientas profesionales', style: TextStyle(color: Colors.grey, fontSize: 14)),
                const SizedBox(height: 40),
                TextFormField(controller: _userCtrl, decoration: InputDecoration(labelText: 'Usuario', prefixIcon: const Icon(Icons.person), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), validator: (v) => v == null || v.trim().isEmpty ? 'Requerido' : null),
                const SizedBox(height: 16),
                TextFormField(controller: _passCtrl, obscureText: true, decoration: InputDecoration(labelText: 'Contraseña', prefixIcon: const Icon(Icons.lock), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), validator: (v) => v == null || v.isEmpty ? 'Requerido' : null),
                const SizedBox(height: 8),
                Align(alignment: Alignment.centerRight, child: Text('admin / admin123', style: TextStyle(color: Colors.grey.shade400, fontSize: 12))),
                const SizedBox(height: 20),
                SizedBox(width: double.infinity, height: 50,
                  child: FilledButton(onPressed: _loading ? null : _login,
                    style: FilledButton.styleFrom(backgroundColor: primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: _loading ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Ingresar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)))),
                const SizedBox(height: 20),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text('No tienes cuenta? '),
                  GestureDetector(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RegistroScreen(onRegistroSuccess: widget.onLoginSuccess))),
                    child: Text('Registrate', style: TextStyle(color: primary, fontWeight: FontWeight.w600))),
                ]),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
