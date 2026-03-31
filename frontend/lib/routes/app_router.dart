import 'package:flutter/material.dart';
import '../main.dart'; // Para acceder a AuthWrapper
import '../views/auth/register_screen.dart';
import '../views/alumno/alumno_home_screen.dart';
import '../views/alumno/historial_screen.dart';
import '../views/alumno/horario_screen.dart';
import '../views/alumno/maestros_screen.dart';
import '../views/alumno/ayuda_screen.dart';
import '../views/alumno/unirse_clase_screen.dart';
import '../views/alumno/clases_screen.dart';
import '../views/maestro/maestro_home_screen.dart';
import '../views/admin/admin_home_screen.dart';

class AppRouter {
  static const String login = '/';
  static const String register = '/register';
  static const String alumnoHome = '/alumno/home';
  static const String alumnoHistorial = '/alumno/historial';
  static const String alumnoHorario = '/alumno/horario';
  static const String alumnoMaestros = '/alumno/maestros';
  static const String alumnoAyuda = '/alumno/ayuda';
  static const String alumnoUnirse = '/alumno/unirse';
  static const String alumnoClases = '/alumno/clases';
  static const String maestroHome = '/maestro/home';
  static const String adminHome = '/admin/home';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const AuthWrapper());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case alumnoHome:
        return MaterialPageRoute(builder: (_) => const AlumnoHomeScreen());
      case alumnoHistorial:
        return MaterialPageRoute(builder: (_) => const HistorialScreen());
      case alumnoHorario:
        return MaterialPageRoute(builder: (_) => const HorarioScreen());
      case alumnoMaestros:
        return MaterialPageRoute(builder: (_) => const MaestrosScreen());
      case alumnoAyuda:
        return MaterialPageRoute(builder: (_) => const AyudaScreen());
      case alumnoUnirse:
        return MaterialPageRoute(builder: (_) => const UnirseClaseScreen());
      case alumnoClases:
        return MaterialPageRoute(builder: (_) => const ClasesScreen());
      case maestroHome:
        return MaterialPageRoute(builder: (_) => const MaestroHomeScreen());
      case adminHome:
        return MaterialPageRoute(builder: (_) => const AdminHomeScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Ruta no encontrada: ${settings.name}')),
          ),
        );
    }
  }
}
