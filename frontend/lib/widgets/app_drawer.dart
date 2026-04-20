import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../controllers/nav_controller.dart';
import '../core/theme/app_theme.dart';
import '../views/perfil/perfil_screen.dart';
import '../routes/app_router.dart';
import '../views/maestro/mis_resenas_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final nav = context.watch<NavController>();
    final user = auth.user;
    final role = user?.role ?? 'alumno';

    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          _buildHeader(context, user),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildMenuItem(
                  context,
                  icon: Icons.person_outline,
                  title: 'Mi Perfil',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const PerfilScreen()));
                  },
                ),
                const Divider(height: 1),

                if (role == 'admin' || role == 'super_admin')
                  ..._buildAdminItems(context, nav),
                if (role == 'alumno')
                  ..._buildAlumnoItems(context),
                if (role == 'maestro')
                  ..._buildMaestroItems(context, nav),

                const Divider(height: 1),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text(
                  'Portal de Calificaciones',
                  style: TextStyle(color: AppTheme.textGray, fontSize: 12, fontWeight: FontWeight.bold),
                ),
                Text(
                  'v1.0.6',
                  style: TextStyle(color: AppTheme.textGray.withValues(alpha: 0.5), fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, dynamic user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 50, bottom: 20, left: 20, right: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryDark, AppTheme.primaryPurple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: Colors.white24,
            backgroundImage: (user?.profilePicture != null && user!.profilePicture!.isNotEmpty)
                ? NetworkImage(user.profilePicture!)
                : null,
            child: (user?.profilePicture == null || user!.profilePicture!.isEmpty)
                ? const Icon(Icons.person, color: Colors.white, size: 35)
                : null,
          ),
          const SizedBox(height: 15),
          Text(
            user?.fullName ?? user?.username ?? 'Usuario',
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            user?.email ?? '',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white30),
            ),
            child: Text(
              (user?.role ?? 'alumno').toString().toUpperCase(),
              style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAdminItems(BuildContext context, NavController nav) {
    return [
      _buildMenuItem(context, icon: Icons.people_alt_outlined, title: 'Panel de Usuarios', onTap: () {
        nav.setAdminIndex(0);
        Navigator.pop(context);
      }),
      _buildMenuItem(context, icon: Icons.calendar_month_outlined, title: 'Gestión de Horarios', onTap: () {
        nav.setAdminIndex(1);
        Navigator.pop(context);
      }),
      _buildMenuItem(context, icon: Icons.rate_review_outlined, title: 'Reseñas del Sistema', onTap: () {
        nav.setAdminIndex(2);
        Navigator.pop(context);
      }),
      _buildMenuItem(context, icon: Icons.support_agent, title: 'Soporte y Ayuda', onTap: () {
        nav.setAdminIndex(3);
        Navigator.pop(context);
      }),
    ];
  }

  List<Widget> _buildAlumnoItems(BuildContext context) {
    return [
      _buildMenuItem(context, icon: Icons.assignment_outlined, title: 'Historial Académico', onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, AppRouter.alumnoHistorial);
      }),
      _buildMenuItem(context, icon: Icons.access_time, title: 'Mi Horario', onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, AppRouter.alumnoHorario);
      }),
      _buildMenuItem(context, icon: Icons.person_search_outlined, title: 'Mis Profesores', onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, AppRouter.alumnoMaestros);
      }),
      _buildMenuItem(context, icon: Icons.laptop_chromebook, title: 'Unirse a Clase', onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, AppRouter.alumnoUnirse);
      }),
      _buildMenuItem(context, icon: Icons.monitor, title: 'Mis Clases', onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, AppRouter.alumnoClases);
      }),
      _buildMenuItem(context, icon: Icons.headset_mic_outlined, title: 'Centro de Ayuda', onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, AppRouter.alumnoAyuda);
      }),
    ];
  }

  List<Widget> _buildMaestroItems(BuildContext context, NavController nav) {
    return [
      _buildMenuItem(context, icon: Icons.class_outlined, title: 'Mis Clases', onTap: () {
        nav.setMaestroIndex(0);
        Navigator.pop(context);
      }),
      _buildMenuItem(context, icon: Icons.star_outline, title: 'Mis Reseñas', onTap: () {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (_) => const MisResenasScreen()));
      }),
      _buildMenuItem(context, icon: Icons.calendar_month, title: 'Consultar Horarios', onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, AppRouter.alumnoHorario);
      }),
    ];
  }

  Widget _buildMenuItem(BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppTheme.primaryDark, size: 22),
      title: Text(
        title,
        style: TextStyle(
          color: color ?? AppTheme.textDark,
          fontWeight: FontWeight.w500,
          fontSize: 14
        )
      ),
      onTap: onTap,
      dense: true,
      visualDensity: VisualDensity.compact,
    );
  }
}
