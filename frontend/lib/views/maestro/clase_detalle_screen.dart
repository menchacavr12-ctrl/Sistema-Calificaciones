import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/api_service.dart';

class ClaseDetalleScreen extends StatefulWidget {
  final Map<String, dynamic> clase;

  const ClaseDetalleScreen({super.key, required this.clase});

  @override
  State<ClaseDetalleScreen> createState() => _ClaseDetalleScreenState();
}

class _ClaseDetalleScreenState extends State<ClaseDetalleScreen> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _alumnos = [];
  int _parcialActual = 1;

  @override
  void initState() {
    super.initState();
    _loadAlumnos();
  }

  Future<void> _loadAlumnos() async {
    setState(() => _isLoading = true);
    try {
      final id = widget.clase['_id'] ?? widget.clase['id'] ?? '';
      final result = await ApiService.get('/api/clases/$id/alumnos');
      setState(() {
        _alumnos = (result as List).map((al) {
          final mapped = Map<String, dynamic>.from(al);
          if (mapped['calificaciones'] != null) {
            for (var c in mapped['calificaciones']) {
              final p = c['parcial'];
              final v = c['valor'];
              mapped['parcial$p'] = v;
            }
          }
          return mapped;
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _alumnos = _alumnosEjemplo();
      });
    }
  }

  List<Map<String, dynamic>> _alumnosEjemplo() {
    return [
      {'username': 'Carlos Méndez', 'parcial1': 95, 'parcial2': 88, 'parcial3': null},
      {'username': 'María López', 'parcial1': 78, 'parcial2': 82, 'parcial3': null},
      {'username': 'Juan Hernández', 'parcial1': 90, 'parcial2': 95, 'parcial3': null},
      {'username': 'Ana García', 'parcial1': 70, 'parcial2': 75, 'parcial3': null},
      {'username': 'Pedro Sánchez', 'parcial1': 85, 'parcial2': null, 'parcial3': null},
      {'username': 'Laura Torres', 'parcial1': 92, 'parcial2': 89, 'parcial3': null},
      {'username': 'Diego Ramírez', 'parcial1': 65, 'parcial2': 70, 'parcial3': null},
      {'username': 'Sofía Ruiz', 'parcial1': 98, 'parcial2': 96, 'parcial3': null},
    ];
  }

  Color _colorNota(num? nota) {
    if (nota == null) return Colors.grey;
    if (nota >= 90) return AppTheme.accentGreen;
    if (nota >= 80) return const Color(0xFF3B82F6);
    if (nota >= 70) return AppTheme.accentOrange;
    return AppTheme.accentRed;
  }

  double _calcularPromedio(Map<String, dynamic> alumno) {
    int count = 0;
    double sum = 0;
    for (int i = 1; i <= 3; i++) {
      final nota = alumno['parcial$i'];
      if (nota != null) {
        sum += (nota as num).toDouble();
        count++;
      }
    }
    return count > 0 ? sum / count : 0;
  }

  void _editarNota(Map<String, dynamic> alumno, int parcial) {
    final controller = TextEditingController(
      text: alumno['parcial$parcial']?.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Calificar P$parcial'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              alumno['username'] ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              '${widget.clase['nombre']} · ${widget.clase['grupo']}',
              style: TextStyle(color: AppTheme.textGray, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Calificación (0-100)',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
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
                final nota = int.tryParse(controller.text);
                if (nota != null && nota >= 0 && nota <= 100) {
                  final scaffoldMsg = ScaffoldMessenger.of(context);
                  try {
                    final claseId = widget.clase['_id'] ?? widget.clase['id'];
                    final alumnoId = alumno['_id'] ?? alumno['id'];
                    await ApiService.put(
                      '/api/clases/$claseId/alumnos/$alumnoId/calificacion/$parcial',
                      {'valor': nota},
                    );
                    setState(() {
                      alumno['parcial$parcial'] = nota;
                    });
                    if (context.mounted) {
                      Navigator.pop(ctx);
                    }
                    scaffoldMsg.showSnackBar(
                      const SnackBar(
                        content: Text(' Calificación actualizada'),
                        backgroundColor: AppTheme.accentGreen,
                      ),
                    );
                  } catch (e) {
                    if (context.mounted) {
                      Navigator.pop(ctx);
                    }
                    scaffoldMsg.showSnackBar(
                      SnackBar(
                        content: Text('Error al modificar calificación: $e'),
                        backgroundColor: AppTheme.accentRed,
                      ),
                    );
                  }
                }
              },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentPurple,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Guardar',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmarEliminar() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Clase'),
        content: const Text('¿Estás seguro de que quieres eliminar esta clase?\nLos alumnos ya no tendrán acceso a ella.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentRed),
            onPressed: () async {
              Navigator.pop(ctx);
              final scaffoldMsg = ScaffoldMessenger.of(context);
              try {
                await ApiService.deleteAuth('/api/clases/${widget.clase['id']}');
                if (mounted) {
                  Navigator.pop(context, true); // Retornar para recargar la lista
                }
                scaffoldMsg.showSnackBar(
                  const SnackBar(content: Text('Clase eliminada'), backgroundColor: AppTheme.accentGreen),
                );
              } catch (e) {
                scaffoldMsg.showSnackBar(
                  SnackBar(content: Text('Error al eliminar: $e'), backgroundColor: AppTheme.accentRed),
                );
              }
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color color = AppTheme.accentPurple;
    final colorVal = widget.clase['color'];
    if (colorVal is int) {
      color = Color(colorVal);
    } else if (colorVal is String && colorVal.isNotEmpty) {
      String hex = colorVal.replaceAll('#', '');
      if (hex.length == 6) hex = 'FF$hex';
      try {
        color = Color(int.parse(hex, radix: 16));
      } catch (_) {}
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: Column(
        children: [

          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.7)],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Expanded(
                          child: Text(
                            widget.clase['nombre'] ?? 'Clase',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.white),
                          onPressed: _confirmarEliminar,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildInfoChip(Icons.group, '${widget.clase['grupo']}'),
                        const SizedBox(width: 12),
                        _buildInfoChip(Icons.people, '${_alumnos.length} alumnos'),
                        const SizedBox(width: 12),
                        _buildInfoChip(Icons.vpn_key, widget.clase['codigo'] ?? ''),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Row(
              children: [
                const Text('Parcial:  ',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                ...List.generate(3, (i) {
                  final p = i + 1;
                  final isSelected = p == _parcialActual;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text('P$p'),
                      selected: isSelected,
                      selectedColor: color,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppTheme.textDark,
                        fontWeight: FontWeight.bold,
                      ),
                      onSelected: (_) =>
                          setState(() => _parcialActual = p),
                    ),
                  );
                }),
              ],
            ),
          ),
          const Divider(height: 1),

          Container(
            color: Colors.grey.shade100,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                const Expanded(
                  flex: 3,
                  child: Text('Alumno',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ),
                SizedBox(
                  width: 60,
                  child: Text('P$_parcialActual',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13)),
                ),
                const SizedBox(
                  width: 60,
                  child: Text('Prom.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13)),
                ),
                const SizedBox(width: 40),
              ],
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
                    itemCount: _alumnos.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final alumno = _alumnos[index];
                      final notaParcial = alumno['parcial$_parcialActual'] as num?;
                      final prom = _calcularPromedio(alumno);

                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        color: index.isEven
                            ? Colors.white
                            : Colors.grey.shade50,
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: color.withValues(alpha: 0.15),
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 3,
                              child: Text(
                                alumno['username'] ?? '',
                                style: const TextStyle(fontSize: 13),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(
                              width: 60,
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: _colorNota(notaParcial)
                                        .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    notaParcial?.toString() ?? '—',
                                    style: TextStyle(
                                      color: _colorNota(notaParcial),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 60,
                              child: Center(
                                child: Text(
                                  prom > 0 ? prom.toStringAsFixed(1) : '—',
                                  style: TextStyle(
                                    color: _colorNota(prom > 0 ? prom : null),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 40,
                              child: IconButton(
                                icon: Icon(Icons.edit,
                                    color: color, size: 18),
                                onPressed: () =>
                                    _editarNota(alumno, _parcialActual),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(text,
              style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
}
