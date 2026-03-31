import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/app_drawer.dart';
import 'historial_screen.dart';
import 'horario_screen.dart';
import 'maestros_screen.dart';
import 'ayuda_screen.dart';
import 'unirse_clase_screen.dart';
import 'clases_screen.dart';
import '../perfil/perfil_screen.dart';

class AlumnoHomeScreen extends StatefulWidget {
  const AlumnoHomeScreen({super.key});

  @override
  State<AlumnoHomeScreen> createState() => _AlumnoHomeScreenState();
}

class _AlumnoHomeScreenState extends State<AlumnoHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> get _menuItems => [
    {
      'title': 'Historial Academico',
      'subtitle': 'Visualiza tus calificaciones en periodos o en general',
      'icon': Icons.assignment,
      'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistorialScreen())),
    },
    {
      'title': 'Mi Horario',
      'subtitle': 'Visualiza tus horarios en este Semestre o generales',
      'icon': Icons.access_time,
      'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HorarioScreen())),
    },
    {
      'title': 'Maestros',
      'subtitle': 'Visualiza y opina sobre tus maestros descubre algunos nuevos...',
      'icon': Icons.person_pin,
      'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MaestrosScreen())),
    },
    {
      'title': 'Ayuda',
      'subtitle': 'Ponte en contacto con nuestro personal para solicitar algún cambio',
      'icon': Icons.headset_mic,
      'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AyudaScreen())),
    },
    {
      'title': 'Unirse a una clase',
      'subtitle': 'Ingresa un código para unirte',
      'icon': Icons.laptop_chromebook,
      'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UnirseClaseScreen())),
    },
    {
      'title': 'CLASES',
      'subtitle': 'Ver tus clases y detalles',
      'icon': Icons.monitor,
      'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ClasesScreen())),
    },
  ];

  List<Map<String, dynamic>> get _filteredItems {
    if (_searchQuery.isEmpty) return _menuItems;
    final q = _searchQuery.toLowerCase();
    return _menuItems.where((item) {
      return item['title'].toString().toLowerCase().contains(q) ||
             item['subtitle'].toString().toLowerCase().contains(q);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final user = auth.user;

    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      backgroundColor: AppTheme.backgroundLight,
      body: Column(
        children: [
          // Header con info del alumno
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.menu, color: Colors.white),
                      onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                    ),
                    const SizedBox(width: 12),
                    // Buscador
                    Expanded(
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) => setState(() => _searchQuery = val),
                          decoration: InputDecoration(
                            hintText: 'Buscar Consultas',
                            hintStyle: const TextStyle(color: AppTheme.textGray, fontSize: 13),
                            prefixIcon: const Icon(Icons.search, color: AppTheme.accentPurple, size: 18),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 10),
                            suffixIcon: _searchQuery.isNotEmpty 
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 16),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                )
                              : null,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Avatar y saludo
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.white24,
                            backgroundImage:
                                (user?.profilePicture != null &&
                                    user!.profilePicture!.isNotEmpty)
                                ? NetworkImage(user.profilePicture!)
                                : null,
                            child:
                                (user?.profilePicture == null ||
                                    user!.profilePicture!.isEmpty)
                                ? const Icon(Icons.person, color: Colors.white)
                                : null,
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Hola ',
                            style: TextStyle(color: Colors.white, fontSize: 10),
                          ),
                          Text(
                            user?.username ?? 'Alumno',
                            style: const TextStyle(
                              color: AppTheme.colorAlumno,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Título
          const Padding(
            padding: EdgeInsets.only(top: 20, bottom: 10),
            child: Text(
              'Consultas Disponibles:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
          ),

          // Grid de opciones
          Expanded(
            child: _filteredItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off,
                            size: 64,
                            color: AppTheme.textGray.withValues(alpha: 0.5)),
                        const SizedBox(height: 16),
                        const Text('No se encontraron consultas',
                            style: TextStyle(color: AppTheme.textGray)),
                      ],
                    ),
                  )
                : GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.85,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = _filteredItems[index];
                      return _MenuCard(
                        title: item['title'],
                        subtitle: item['subtitle'],
                        icon: item['icon'],
                        onTap: item['onTap'],
                      );
                    },
                  ),
          ),

          // Barra inferior
          Container(
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.backgroundGray,
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, -2))
              ]
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Icon(Icons.home, color: Colors.white),
                IconButton(
                  icon: const Icon(Icons.person, color: Colors.white70),
                  onPressed: () => _showLogoutDialog(context, auth),
                ),
              ],
            ),
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
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await Provider.of<AuthController>(context, listen: false).logout();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentRed,
            ),
            child: const Text(
              'Cerrar Sesión',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _MenuCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppTheme.textGray,
                  ),
                ),
              ),
              const Spacer(),
              Icon(icon, size: 48, color: Colors.black87),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 30,
                child: ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  child: const Text(
                    'Consultar',
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
