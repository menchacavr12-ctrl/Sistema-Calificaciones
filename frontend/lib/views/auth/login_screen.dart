import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common/app_header.dart';
import '../../widgets/common/app_buttons.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  bool _obscurePass = true;

  @override
  void dispose() {
    _userController.dispose();
    _passController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthController>();

    final result = await auth.login(
      emailOrUsername: _userController.text.trim(),
      password: _passController.text,
    );

    if (result != null && mounted) {
      if (auth.user != null) {
        _navigateByRole(auth.user!.role);
      }
    } else if (auth.error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error!), backgroundColor: AppTheme.accentRed),
      );
    }
  }

  void _navigateByRole(String role) {
    switch (role) {
      case 'alumno':
        Navigator.pushReplacementNamed(context, '/alumno/home');
        break;
      case 'maestro':
        Navigator.pushReplacementNamed(context, '/maestro/home');
        break;
      case 'admin':
      case 'super_admin':
        Navigator.pushReplacementNamed(context, '/admin/home');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    return Scaffold(
      body: Column(
        children: [
          // ── Header con degradado ────────────────────────────────────
          const AppHeader(),

          // ── Imagen de estudiantes ───────────────────────────────────
          Container(
            height: 140,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryDark, Color(0xFF3949AB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Imagen de fondo (estudiantes)
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryDark,
                        AppTheme.accentPurple.withValues(alpha: 0.8),
                      ],
                    ),
                  ),
                ),
                // Íconos decorativos
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person, size: 60, color: Colors.white.withValues(alpha: 0.3)),
                    Icon(Icons.person, size: 80, color: Colors.white.withValues(alpha: 0.5)),
                    Icon(Icons.person, size: 60, color: Colors.white.withValues(alpha: 0.3)),
                  ],
                ),
              ],
            ),
          ),

          // ── Formulario ───────────────────────────────────────────────
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
                        'Inicio de sesion',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Campo usuario/correo
                      AppTextField(
                        label: 'Usuario o correo electronico',
                        controller: _userController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Ingresa tu usuario o correo' : null,
                      ),
                      const SizedBox(height: 16),

                      // Campo contraseña
                      AppTextField(
                        label: 'Contraseña',
                        controller: _passController,
                        obscureText: _obscurePass,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Ingresa tu contraseña' : null,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePass ? Icons.visibility_off : Icons.visibility,
                            color: AppTheme.textGray,
                          ),
                          onPressed: () => setState(() => _obscurePass = !_obscurePass),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Botón Iniciar Sesion (verde)
                      GreenButton(
                        text: 'Ingresar',
                        onPressed: _handleLogin,
                        isLoading: auth.isLoading,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Footer: Registrarse ─────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            color: AppTheme.backgroundLight,
            child: Column(
              children: [
                const Text(
                  '¿Aun no tienes una cuenta?',
                  style: TextStyle(color: AppTheme.textGray),
                ),
                const SizedBox(height: 10),
                PurpleButton(
                  text: 'Registrate',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
