import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/api_service.dart';

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  bool _isLoading = true;
  List<dynamic> _historial = [];
  List<dynamic> _filteredHistorial = [];
  double _globalAvg = 0.0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHistorial();
  }

  void _computeGlobalAvg() {
    if (_historial.isEmpty) {
      _globalAvg = 0.0;
      return;
    }
    double sum = 0;
    int count = 0;
    for (var m in _historial) {
      List<dynamic> califs = m['calificaciones'] ?? [];
      List<num> validas = [];
      for (var c in califs) {
        if (c['valor'] != null) validas.add(c['valor'] as num);
      }
      if (validas.isNotEmpty) {
        sum += validas.reduce((a, b) => a + b) / validas.length;
        count++;
      }
    }
    _globalAvg = count > 0 ? (sum / count) : 0.0;
  }

  Future<void> _loadHistorial() async {
    setState(() => _isLoading = true);
    try {
      final result = await ApiService.get('/api/clases/historial');
      setState(() {
        if (result is Map) {
          _historial = result['historial'] is List ? result['historial'] : [];
          _filteredHistorial = _historial;
          _computeGlobalAvg();
        } else {
          _historial = [];
          _filteredHistorial = [];
          _globalAvg = 0.0;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _isLoading = false;
        _historial = [];
        _filteredHistorial = [];
      });
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredHistorial = _historial;
      } else {
        final q = query.toLowerCase();
        _filteredHistorial = _historial.where((m) {
          final materia = (m['nombre_materia'] ?? '').toString().toLowerCase();
          final maestro = (m['maestro'] ?? '').toString().toLowerCase();
          return materia.contains(q) || maestro.contains(q);
        }).toList();
      }
    });
  }

  double get _promedioGeneral => _globalAvg;

  Color _colorNota(num nota) {
    if (nota >= 90) return AppTheme.accentGreen;
    if (nota >= 80) return const Color(0xFF3B82F6);
    if (nota >= 70) return AppTheme.accentOrange;
    return AppTheme.accentRed;
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().user;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: Column(
        children: [

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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        'Historial Académico',
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
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.accentPurple,
                  AppTheme.accentPurple.withValues(alpha: 0.7),
                ],
              ),
            ),
            child: Column(
              children: [
                const Text('Promedio Semestral',
                    style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 6),
                Text(
                  _promedioGeneral.toStringAsFixed(1),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user?.username ?? 'Alumno',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: TextField(
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Buscar materia o maestro...',
                prefixIcon: const Icon(Icons.search, color: AppTheme.accentPurple),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: AppTheme.accentPurple, width: 1),
                ),
              ),
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredHistorial.isEmpty && _error == null
                  ? const Center(child: Text('No hay materias que coincidan.'))
                  : _error != null
                    ? Center(child: Text(_error!, style: const TextStyle(color: AppTheme.accentRed)))
                    : RefreshIndicator(
                        onRefresh: _loadHistorial,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  headingRowColor: WidgetStateProperty.all(AppTheme.primaryDark.withValues(alpha: 0.05)),
                                  headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryDark),
                                  columnSpacing: 25,
                                  columns: const [
                                    DataColumn(label: Text('Materia')),
                                    DataColumn(label: Text('Parcial 1', textAlign: TextAlign.center)),
                                    DataColumn(label: Text('Parcial 2', textAlign: TextAlign.center)),
                                    DataColumn(label: Text('Parcial 3', textAlign: TextAlign.center)),
                                    DataColumn(label: Text('Promedio', textAlign: TextAlign.center)),
                                  ],
                                  rows: _filteredHistorial.map((m) {
                                    num getCal(int p) {
                                      final califs = m['calificaciones'] as List<dynamic>? ?? [];
                                      final elem = califs.firstWhere(
                                          (c) => c['parcial'] == p,
                                          orElse: () => {'valor': 0});
                                      return (elem['valor'] ?? 0) as num;
                                    }

                                    final p1 = getCal(1);
                                    final p2 = getCal(2);
                                    final p3 = getCal(3);

                                    final califsL = m['calificaciones'] as List<dynamic>? ?? [];
                                    final filter = califsL.where((c) => c['valor'] != null).map((e) => e['valor'] as num).toList();
                                    final avg = filter.isNotEmpty ? filter.reduce((a, b) => a + b) / filter.length : 0.0;

                                    return DataRow(
                                      cells: [
                                        DataCell(
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(m['nombre_materia'] ?? 'Sin asignar', style: const TextStyle(fontWeight: FontWeight.w600)),
                                              Text(m['maestro'] ?? '', style: const TextStyle(fontSize: 10, color: AppTheme.textGray)),
                                            ],
                                          ),
                                        ),
                                        DataCell(Center(child: Text(p1.toString(), style: TextStyle(color: _colorNota(p1), fontWeight: FontWeight.bold)))),
                                        DataCell(Center(child: Text(p2.toString(), style: TextStyle(color: _colorNota(p2), fontWeight: FontWeight.bold)))),
                                        DataCell(Center(child: Text(p3.toString(), style: TextStyle(color: _colorNota(p3), fontWeight: FontWeight.bold)))),
                                        DataCell(
                                          Center(
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: _colorNota(avg),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(avg.toStringAsFixed(1), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
