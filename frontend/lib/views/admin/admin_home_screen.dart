import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/nav_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/app_drawer.dart';
import 'admin_usuarios_tab.dart';
import 'admin_horarios_tab.dart';
import 'admin_resenas_tab.dart';
import 'admin_ayuda_tab.dart';
import '../perfil/perfil_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> _tabs = [
    const AdminUsuariosTab(),
    const AdminHorariosTab(),
    const AdminResenasTab(),
    const AdminAyudaTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final nav = context.watch<NavController>();
    final user = auth.user;
    final currentIndex = nav.adminIndex;

    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      backgroundColor: AppTheme.backgroundLight,
      body: Column(
        children: [
          // Header Moderno
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryDark, AppTheme.primaryPurple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.menu, color: Colors.white),
                      onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Panel de Control',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Administrador: ${user?.username ?? "Admin"}',
                          style: const TextStyle(
                            color: AppTheme.colorAdmin,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'perfil') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PerfilScreen(),
                            ),
                          );
                        } else if (value == 'logout') {
                          _showLogoutDialog(context, auth);
                        }
                      },
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(
                              value: 'perfil',
                              child: Row(
                                children: [
                                  Icon(Icons.person, color: AppTheme.textGray),
                                  SizedBox(width: 8),
                                  Text('Mi Perfil'),
                                ],
                              ),
                            ),
                            const PopupMenuItem<String>(
                              value: 'logout',
                              child: Row(
                                children: [
                                  Icon(Icons.logout, color: AppTheme.accentRed),
                                  SizedBox(width: 8),
                                  Text('Cerrar Sesión'),
                                ],
                              ),
                            ),
                          ],
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        backgroundImage:
                            (user?.profilePicture != null &&
                                user!.profilePicture!.isNotEmpty)
                            ? NetworkImage(user.profilePicture!)
                            : null,
                        child:
                            (user?.profilePicture == null ||
                                user!.profilePicture!.isEmpty)
                            ? const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 20,
                              )
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Content
          Expanded(
            child: IndexedStack(
              index: currentIndex,
              children: _tabs,
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => nav.setAdminIndex(index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryPurple,
        unselectedItemColor: AppTheme.textGray,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_outlined),
            activeIcon: Icon(Icons.people_alt),
            label: 'Usuarios',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month),
            label: 'Horarios',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.rate_review_outlined),
            activeIcon: Icon(Icons.rate_review),
            label: 'Reseñas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.support_agent),
            activeIcon: Icon(Icons.support_agent),
            label: 'Ayuda',
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthController auth) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Deseas salir del sistema?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await Provider.of<AuthController>(context, listen: false).logout();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentRed),
            child: const Text('Cerrar Sesión',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
