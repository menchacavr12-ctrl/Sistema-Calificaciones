import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/api_service.dart';
import 'resena_maestro_screen.dart';

class MaestrosScreen extends StatefulWidget {
  const MaestrosScreen({super.key});

  @override
  State<MaestrosScreen> createState() => _MaestrosScreenState();
}

class _MaestrosScreenState extends State<MaestrosScreen> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _maestros = [];
  String _searchQuery = '';
  String _filtroEspecialidad = 'Todas';

  final List<String> _especialidades = [
    'Todas', 'Programación', 'Matemáticas', 'Ciencias', 'Idiomas', 'Otras'
  ];

  @override
  void initState() {
    super.initState();
    _loadMaestros();
  }

  Future<void> _loadMaestros() async {
    setState(() => _isLoading = true);
    try {
      final result = await ApiService.get('/api/usuarios/maestros');
      setState(() {
        _maestros = (result as List).cast<Map<String, dynamic>>();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _maestros = _maestrosEjemplo();
      });
    }
  }

  List<Map<String, dynamic>> _maestrosEjemplo() {
    return [
      {
        'username': 'Prof. García',
        'email': 'garcia@escuela.edu',
        'especialidad': 'Programación',
        'materias': ['Programación', 'Base de Datos'],
        'rating': 4.5,
        'total_opiniones': 23,
      },
      {
        'username': 'Prof. López',
        'email': 'lopez@escuela.edu',
        'especialidad': 'Matemáticas',
        'materias': ['Matemáticas', 'Cálculo'],
        'rating': 4.2,
        'total_opiniones': 18,
      },
      {
        'username': 'Prof. Smith',
        'email': 'smith@escuela.edu',
        'especialidad': 'Idiomas',
        'materias': ['Inglés', 'Francés'],
        'rating': 4.8,
        'total_opiniones': 31,
      },
      {
        'username': 'Prof. Martínez',
        'email': 'martinez@escuela.edu',
        'especialidad': 'Ciencias',
        'materias': ['Física', 'Laboratorio'],
        'rating': 3.9,
        'total_opiniones': 15,
      },
      {
        'username': 'Prof. Rodríguez',
        'email': 'rodriguez@escuela.edu',
        'especialidad': 'Ciencias',
        'materias': ['Química', 'Biología'],
        'rating': 4.1,
        'total_opiniones': 20,
      },
    ];
  }

  List<Map<String, dynamic>> get _filtrados {
    return _maestros.where((m) {
      final nombre = (m['username'] ?? '').toString().toLowerCase();
      final matchSearch = nombre.contains(_searchQuery.toLowerCase());
      final matchEspecialidad = _filtroEspecialidad == 'Todas' ||
          m['especialidad'] == _filtroEspecialidad;
      return matchSearch && matchEspecialidad;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(gradient: headerGradient),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        'Maestros',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
            ),
          ),

          // ── Buscador ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Buscar maestro...',
                prefixIcon:
                    const Icon(Icons.search, color: AppTheme.accentPurple),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),

          // ── Filtros de especialidad ─────────────────────────
          SizedBox(
            height: 36,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _especialidades.length,
              itemBuilder: (context, index) {
                final esp = _especialidades[index];
                final isSelected = esp == _filtroEspecialidad;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(esp, style: const TextStyle(fontSize: 12)),
                    selected: isSelected,
                    selectedColor: AppTheme.accentPurple,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.textDark,
                    ),
                    onSelected: (_) =>
                        setState(() => _filtroEspecialidad = esp),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // ── Lista de maestros ───────────────────────────────
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filtrados.isEmpty
                    ? const Center(
                        child: Text('No se encontraron maestros',
                            style: TextStyle(color: AppTheme.textGray)),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: _filtrados.length,
                        itemBuilder: (context, index) {
                          return _buildMaestroCard(_filtrados[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaestroCard(Map<String, dynamic> maestro) {
    final rating = (maestro['rating'] ?? 0).toDouble();
    final materias = (maestro['materias'] as List?)?.join(', ') ?? '';
    final profilePic = maestro['profile_picture'];

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResenaMaestroScreen(maestro: maestro),
            ),
          ).then((_) {
            _loadMaestros(); // Recargar al volver para ver su nuevo promedio
          });
        },
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 28,
                backgroundColor: AppTheme.accentPurple.withValues(alpha: 0.15),
                backgroundImage: (profilePic != null && profilePic.isNotEmpty)
                    ? NetworkImage(profilePic)
                    : null,
                child: (profilePic == null || profilePic.isEmpty)
                    ? Text(
                        (maestro['username'] ?? 'M')[0].toUpperCase(),
                        style: const TextStyle(
                          color: AppTheme.accentPurple,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Text(
                    maestro['username'] ?? '',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    maestro['especialidad'] ?? '',
                    style: TextStyle(
                      color: AppTheme.accentPurple,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    materias,
                    style: TextStyle(color: AppTheme.textGray, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Rating
            Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: Color(0xFFF59E0B), size: 18),
                    const SizedBox(width: 2),
                    Text(
                      rating.toStringAsFixed(1),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
                Text(
                  '${maestro['total_opiniones'] ?? 0} opiniones',
                  style: TextStyle(color: AppTheme.textGray, fontSize: 10),
                ),
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }
}
