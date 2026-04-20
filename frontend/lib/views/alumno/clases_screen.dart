import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/api_service.dart';

class ClasesScreen extends StatefulWidget {
  const ClasesScreen({super.key});

  @override
  State<ClasesScreen> createState() => _ClasesScreenState();
}

class _ClasesScreenState extends State<ClasesScreen> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _clases = [];

  @override
  void initState() {
    super.initState();
    _loadClases();
  }

  Future<void> _loadClases() async {
    setState(() => _isLoading = true);
    try {
      final result = await ApiService.get('/api/clases/mis-clases');
      setState(() {
        _clases = (result as List).cast<Map<String, dynamic>>();
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar clases: $e'), backgroundColor: AppTheme.accentRed),
        );
      }
      setState(() {
        _isLoading = false;
        _clases = [];
      });
    }
  }

  Color _colorNota(double nota) {
    if (nota >= 90) return AppTheme.accentGreen;
    if (nota >= 80) return const Color(0xFF3B82F6);
    if (nota >= 70) return AppTheme.accentOrange;
    return AppTheme.accentRed;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: Column(
        children: [

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
                        'Mis Clases',
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

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildResumenItem(
                  '${_clases.length}',
                  'Clases',
                  Icons.class_,
                  AppTheme.accentPurple,
                ),
                Container(width: 1, height: 40, color: Colors.grey.shade300),
                _buildResumenItem(
                  'P2',
                  'Parcial Actual',
                  Icons.calendar_today,
                  AppTheme.accentGreen,
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadClases,
                    child: _clases.isEmpty
                        ? SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height * 0.5,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.class_outlined, size: 64, color: AppTheme.textGray.withValues(alpha: 0.5)),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'Aún no estás inscrito en ninguna clase',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Tus maestros te darán un código para unirte.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 14, color: AppTheme.textGray),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: _clases.length,
                            itemBuilder: (context, index) {
                              return _buildClaseCard(_clases[index]);
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumenItem(
      String value, String label, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 18, color: color)),
        Text(label,
            style: TextStyle(color: AppTheme.textGray, fontSize: 11)),
      ],
    );
  }

  Widget _buildClaseCard(Map<String, dynamic> clase) {
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

    final promedio = (clase['mi_promedio'] ?? 0).toDouble();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            height: 8,
            color: color,
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.class_, color: color, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            clase['nombre'] ?? '',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            '${clase['maestro']}  ·  ${clase['grupo']}',
                            style: TextStyle(
                                color: AppTheme.textGray, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _colorNota(promedio),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        promedio.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.people, size: 14, color: AppTheme.textGray),
                    const SizedBox(width: 4),
                    Text(
                      '${clase['total_alumnos']} alumnos',
                      style:
                          TextStyle(color: AppTheme.textGray, fontSize: 12),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.vpn_key, size: 14, color: AppTheme.textGray),
                    const SizedBox(width: 4),
                    Text(
                      clase['codigo'] ?? '',
                      style: TextStyle(
                        color: AppTheme.textGray,
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
