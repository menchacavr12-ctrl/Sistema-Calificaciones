import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/nav_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/api_service.dart';
import '../perfil/perfil_screen.dart';
import 'clase_detalle_screen.dart';
import 'mis_resenas_screen.dart';
import '../alumno/horario_screen.dart';
import '../../widgets/app_drawer.dart';

class MaestroHomeScreen extends StatefulWidget {
  const MaestroHomeScreen({super.key});

  @override
  State<MaestroHomeScreen> createState() => _MaestroHomeScreenState();
}

class _MaestroHomeScreenState extends State<MaestroHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = false;
  List<Map<String, dynamic>> _clases = [];
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> get _filteredClases {
    if (_searchQuery.isEmpty) return _clases;
    final q = _searchQuery.toLowerCase();
    return _clases.where((c) {
      final name = (c['nombre'] as String).toLowerCase();
      final group = (c['grupo'] as String).toLowerCase();
      return name.contains(q) || group.contains(q);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadClases();
  }

  Future<void> _loadClases() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiService.get('/api/clases/maestro/mis-clases');
      setState(() {
        _clases = (res as List).cast<Map<String, dynamic>>();
      });
    } catch (e) {
      debugPrint("Error loading classes: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final nav = context.watch<NavController>();
    final user = auth.user;
    final selectedTab = nav.maestroIndex;

    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      backgroundColor: AppTheme.backgroundLight,
      body: Column(
        children: [
          // Header
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
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.menu, color: Colors.white),
                      onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                    ),
                    const Spacer(),
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.school, color: Colors.white, size: 20),
                        ),
                        const SizedBox(height: 4),
                        const Text('Sistema de calificaciones',
                            style: TextStyle(color: Colors.white, fontSize: 11)),
                        const Text('EmilianitoProGamer',
                            style: TextStyle(color: Colors.white70, fontSize: 10)),
                      ],
                    ),
                    const Spacer(),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'perfil') {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const PerfilScreen()));
                        } else if (value == 'resenas') {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const MisResenasScreen()));
                        } else if (value == 'horario') {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const HorarioScreen()));
                        } else if (value == 'logout') {
                          _showLogoutDialog(context, auth);
                        }
                      },
                      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'perfil',
                          child: Row(children: [Icon(Icons.person, color: AppTheme.textGray), SizedBox(width: 8), Text('Mi Perfil')]),
                        ),
                        const PopupMenuItem<String>(
                          value: 'resenas',
                          child: Row(children: [Icon(Icons.star, color: Color(0xFFF59E0B)), SizedBox(width: 8), Text('Mis Reseñas')]),
                        ),
                        const PopupMenuItem<String>(
                          value: 'horario',
                          child: Row(children: [Icon(Icons.calendar_month, color: AppTheme.accentPurple), SizedBox(width: 8), Text('Mi Horario')]),
                        ),
                        const PopupMenuItem<String>(
                          value: 'logout',
                          child: Row(children: [Icon(Icons.logout, color: AppTheme.accentRed), SizedBox(width: 8), Text('Cerrar Sesión')]),
                        ),
                      ],
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        backgroundImage: (user?.profilePicture != null && user!.profilePicture!.isNotEmpty) 
                            ? NetworkImage(user.profilePicture!) 
                            : null,
                        child: (user?.profilePicture == null || user!.profilePicture!.isEmpty)
                            ? const Icon(Icons.person, color: Colors.white, size: 20)
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Contenido principal según la pestaña
          Expanded(
            child: IndexedStack(
              index: selectedTab,
              children: [
                _buildClasesTab(user),
                // Aquí se podrían añadir más pestañas permanentes si fuera necesario
                const Center(child: Text("Otras opciones disponibles en el menú lateral")),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: selectedTab == 0 ? FloatingActionButton(
        onPressed: _showCrearClaseDialog,
        backgroundColor: Colors.white,
        child: const Icon(Icons.add, color: AppTheme.textDark, size: 28),
      ) : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedTab,
        onTap: (index) => nav.setMaestroIndex(index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.class_outlined), activeIcon: Icon(Icons.class_rounded), label: 'Mis Clases'),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'Más'),
        ],
      ),
    );
  }

  Widget _buildClasesTab(dynamic user) {
    return Column(
      children: [
        // Saludo Maestro
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 4),
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 16, color: AppTheme.textDark),
              children: [
                const TextSpan(text: 'Hola '),
                const TextSpan(
                  text: 'Maestro ',
                  style: TextStyle(
                    color: AppTheme.colorMaestro,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: user?.username ?? 'Martin',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),

        // Título y Buscador
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Text('Mis clases',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const Spacer(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() => _searchQuery = val),
                      decoration: InputDecoration(
                        hintText: 'Buscar...',
                        hintStyle: const TextStyle(fontSize: 13, color: AppTheme.textGray),
                        prefixIcon: const Icon(Icons.search, size: 18, color: AppTheme.accentPurple),
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
              ),
            ],
          ),
        ),

        Expanded(
          child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _filteredClases.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.class_outlined, size: 64, color: AppTheme.textGray.withValues(alpha: 0.5)),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty ? 'No tienes clases aún' : 'No se encontraron clases',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _searchQuery.isEmpty 
                              ? 'Presiona el botón + abajo para crear tu primera clase.'
                              : 'Intenta con otro nombre o grupo.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 14, color: AppTheme.textGray),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _filteredClases.length,
            itemBuilder: (context, index) {
              final clase = _filteredClases[index];
              
              Color color = AppTheme.accentPurple;
              final colorVal = clase['color'];
              if (colorVal is int) {
                color = Color(colorVal);
              } else if (colorVal is String && colorVal.isNotEmpty) {
                String hex = colorVal.replaceAll('#', '');
                if (hex.length == 6) hex = 'FF$hex';
                try {
                  color = Color(int.parse(hex, radix: 16));
                } catch (_) {}
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  title: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          clase['grupo'] as String,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          clase['nombre'] as String,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      '${clase['total_alumnos']} alumnos  ·  Código: ${clase['codigo']}',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7), fontSize: 12),
                    ),
                  ),
                  trailing:
                      const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 18),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ClaseDetalleScreen(clase: clase),
                      ),
                    );
                    _loadClases();
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showCrearClaseDialog() {
    final nombreCtrl = TextEditingController();
    final grupoCtrl = TextEditingController();
    final semestreCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Crear Nueva Clase'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nombreCtrl,
              decoration: InputDecoration(
                labelText: 'Nombre de la materia',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: grupoCtrl,
              decoration: InputDecoration(
                labelText: 'Grupo (ej: 6°C)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: semestreCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Semestre (ej: 6)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nombreCtrl.text.isNotEmpty && grupoCtrl.text.isNotEmpty && semestreCtrl.text.isNotEmpty) {
                final scaffoldMsg = ScaffoldMessenger.of(context);
                try {
                  await ApiService.postAuth('/api/clases/', {
                    'nombre': nombreCtrl.text.trim(),
                    'grupo': grupoCtrl.text.trim(),
                    'semestre': int.tryParse(semestreCtrl.text.trim()) ?? 1,
                    'color': '#7C3AED', // Color por defecto
                  });
                  if (mounted) {
                    Navigator.pop(ctx);
                  }
                  _loadClases();
                  scaffoldMsg.showSnackBar(
                    const SnackBar(content: Text('Clase creada con éxito'), backgroundColor: AppTheme.accentGreen),
                  );
                } catch (e) {
                  scaffoldMsg.showSnackBar(
                    SnackBar(content: Text('Error al crear clase: $e'), backgroundColor: AppTheme.accentRed),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentPurple,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Crear', style: TextStyle(color: Colors.white)),
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
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentRed),
            child: const Text('Cerrar Sesión',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
