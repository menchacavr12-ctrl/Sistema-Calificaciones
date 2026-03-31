import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common/app_header.dart';
import '../../widgets/common/app_buttons.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthController>();

    final result = await auth.register(
      username: _usernameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
      confirmPassword: _confirmPassCtrl.text,
    );

    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registro exitoso. Ahora puedes iniciar sesión.'),
          backgroundColor: AppTheme.primaryDark,
        ),
      );
      Navigator.pop(context); // Regresar al Login
    } else if (auth.error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error!), backgroundColor: AppTheme.accentRed),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    return Scaffold(
      body: Column(
        children: [
          const AppHeader(showBack: true),

          // Imagen de estudiantes
          Container(
            height: 120,
            width: double.infinity,
            color: AppTheme.primaryDark,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person, size: 50, color: Colors.white.withValues(alpha: 0.3)),
                Icon(Icons.person, size: 65, color: Colors.white.withValues(alpha: 0.5)),
                Icon(Icons.person, size: 50, color: Colors.white.withValues(alpha: 0.3)),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Registro',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 24),

                      AppTextField(
                        label: 'Nombre de usuario',
                        controller: _usernameCtrl,
                        validator: (v) => v == null || v.length < 3
                            ? 'Mínimo 3 caracteres'
                            : null,
                      ),
                      const SizedBox(height: 14),

                      AppTextField(
                        label: 'Correo electronico',
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Ingresa tu correo';
                          if (!v.contains('@')) return 'Correo inválido';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      AppTextField(
                        label: 'Contraseña',
                        controller: _passCtrl,
                        obscureText: _obscurePass,
                        validator: (v) => v == null || v.length < 6
                            ? 'Mínimo 6 caracteres'
                            : null,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePass ? Icons.visibility_off : Icons.visibility,
                            color: AppTheme.textGray,
                          ),
                          onPressed: () =>
                              setState(() => _obscurePass = !_obscurePass),
                        ),
                      ),
                      const SizedBox(height: 14),

                      AppTextField(
                        label: 'Confirmar Contraseña',
                        controller: _confirmPassCtrl,
                        obscureText: _obscureConfirm,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Confirma tu contraseña';
                          if (v != _passCtrl.text) return 'Las contraseñas no coinciden';
                          return null;
                        },
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                            color: AppTheme.textGray,
                          ),
                          onPressed: () =>
                              setState(() => _obscureConfirm = !_obscureConfirm),
                        ),
                      ),
                      const SizedBox(height: 24),

                      GreenButton(
                        text: 'Registrarse',
                        onPressed: _handleRegister,
                        isLoading: auth.isLoading,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.all(20),
            color: AppTheme.backgroundLight,
            child: Column(
              children: [
                const Text(
                  '¿Ya tienes una cuenta?',
                  style: TextStyle(color: AppTheme.textGray),
                ),
                const SizedBox(height: 10),
                PurpleButton(
                  text: 'Inicia sesion',
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
