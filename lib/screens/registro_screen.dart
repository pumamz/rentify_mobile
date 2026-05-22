import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../config/app_config.dart';

class RegistroScreen extends StatefulWidget {
  final VoidCallback? onRegistroSuccess;
  const RegistroScreen({super.key, this.onRegistroSuccess});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _form = GlobalKey<FormState>();
  final _auth = AuthService();
  final _userCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;

  Future<void> _registrar() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    final r = await _auth.registrar(_userCtrl.text.trim(), _passCtrl.text, _nameCtrl.text.trim(), _emailCtrl.text.trim());
    if (!mounted) return;
    setState(() => _loading = false);
    if (r['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cuenta creada!'), backgroundColor: Colors.green));
      widget.onRegistroSuccess?.call();
      if (mounted) Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(r['message'] ?? 'Error'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Color(AppConfig.primaryColor);
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Cuenta')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(key: _form, child: Column(children: [
          const SizedBox(height: 16),
          TextFormField(controller: _userCtrl, decoration: InputDecoration(labelText: 'Usuario', prefixIcon: const Icon(Icons.person), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), validator: (v) => v == null || v.trim().isEmpty ? 'Requerido' : null),
          const SizedBox(height: 16),
          TextFormField(controller: _nameCtrl, decoration: InputDecoration(labelText: 'Nombre completo', prefixIcon: const Icon(Icons.badge), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), validator: (v) => v == null || v.trim().isEmpty ? 'Requerido' : null),
          const SizedBox(height: 16),
          TextFormField(controller: _emailCtrl, decoration: InputDecoration(labelText: 'Email', prefixIcon: const Icon(Icons.email), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), keyboardType: TextInputType.emailAddress, validator: (v) => v == null || !v.contains('@') ? 'Email invalido' : null),
          const SizedBox(height: 16),
          TextFormField(controller: _passCtrl, obscureText: true, decoration: InputDecoration(labelText: 'Contraseña', prefixIcon: const Icon(Icons.lock), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), validator: (v) => v == null || v.length < 6 ? 'Minimo 6 caracteres' : null),
          const SizedBox(height: 24),
          SizedBox(width: double.infinity, height: 50,
            child: FilledButton(onPressed: _loading ? null : _registrar, style: FilledButton.styleFrom(backgroundColor: primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: _loading ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Crear Cuenta', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)))),
        ])),
      ),
    );
  }

  @override
  void dispose() {
    _userCtrl.dispose(); _nameCtrl.dispose(); _emailCtrl.dispose(); _passCtrl.dispose();
    super.dispose();
  }
}
