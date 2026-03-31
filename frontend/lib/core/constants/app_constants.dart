import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class AppConstants {
  // URL base del backend - se auto-detecta según la plataforma
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000'; // Chrome/Web
    }
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:8000'; // Android Emulator
      }
    } catch (_) {}
    return 'http://localhost:8000'; // iOS / Desktop / Fallback
  }

  // Endpoints
  static const String registerEndpoint = '/api/auth/register';
  static const String loginEndpoint = '/api/auth/login';
  static const String profileEndpoint = '/api/usuarios/me';
  static const String maestrosEndpoint = '/api/usuarios/maestros';
  static const String clasesEndpoint = '/api/clases';
  static const String historialEndpoint = '/api/clases/historial';
  static const String horarioEndpoint = '/api/horarios/me';
  
  // Admin Endpoints
  static const String adminUsuariosEndpoint = '/api/admin/usuarios';
  static const String adminChatListaEndpoint = '/api/admin/chat/alumnos';
  static const String adminChatManoEndpoint = '/api/admin/chat/'; // + id
  static const String adminHorarioGrupoEndpoint = '/api/horarios/grupo';
  
  // Alumno Chat Endpoint
  static const String alumnoChatEndpoint = '/api/ayuda/chat';

  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';

  // App info
  static const String appName = 'Sistema de Calificaciones';
  static const String appNameFull = 'EmilianitoProGamer';

  // Roles
  static const String roleAlumno = 'alumno';
  static const String roleMaestro = 'maestro';
  static const String roleAdmin = 'admin';
  static const String roleSuperAdmin = 'super_admin';
}
