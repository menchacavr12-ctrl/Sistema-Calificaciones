import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/auth_controller.dart';
import 'controllers/nav_controller.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_router.dart';
import 'views/auth/login_screen.dart';
import 'views/alumno/alumno_home_screen.dart';
import 'views/maestro/maestro_home_screen.dart';
import 'views/admin/admin_home_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => NavController()),
      ],
      child: const CalificacionesApp(),
    ),
  );
}

class CalificacionesApp extends StatelessWidget {
  const CalificacionesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistema de Calificaciones EmilianitoProGamer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      onGenerateRoute: AppRouter.generateRoute,
      home: Consumer<AuthController>(
        builder: (context, auth, _) {
          return const AuthWrapper();
        },
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkInitialSession();
  }

  Future<void> _checkInitialSession() async {
    final auth = context.read<AuthController>();
    await auth.checkSession();
    if (mounted) {
      setState(() => _isChecking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    if (_isChecking) {
      return const _SplashScreen();
    }

    if (!auth.isAuthenticated || auth.user == null) {
      return const LoginScreen();
    }

    final role = auth.user!.role;
    switch (role) {
      case 'alumno':
        return const AlumnoHomeScreen();
      case 'maestro':
        return const MaestroHomeScreen();
      case 'admin':
      case 'super_admin':
        return const AdminHomeScreen();
      default:
        return const LoginScreen();
    }
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.school, size: 70, color: Colors.white),
            ),
            const SizedBox(height: 20),
            const Text(
              'Sistema de Calificaciones',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'EmilianitoProGamer',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
