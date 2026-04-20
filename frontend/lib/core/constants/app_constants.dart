class AppConstants {
  // conexion al server
  static String get baseUrl {
    return "https://sistema-calificaciones-z8oy.onrender.com";
  }

  static String get wsBaseUrl {
    if (baseUrl.startsWith("https")) {
      return baseUrl.replaceFirst("https", "wss");
    } else {
      return baseUrl.replaceFirst("http", "ws");
    }
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

  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';

  static const String appName = 'Sistema de Calificaciones';
  static const String appNameFull = 'EmilianitoProGamer';

  static const String roleAlumno = 'alumno';
  static const String roleMaestro = 'maestro';
  static const String roleAdmin = 'admin';
  static const String roleSuperAdmin = 'super_admin';
}
