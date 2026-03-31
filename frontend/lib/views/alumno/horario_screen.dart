import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/api_service.dart';
import '../../core/constants/app_constants.dart';

class HorarioScreen extends StatefulWidget {
  const HorarioScreen({super.key});

  @override
  State<HorarioScreen> createState() => _HorarioScreenState();
}

class _HorarioScreenState extends State<HorarioScreen> {
  final List<String> _dias = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes'];
  int _diaActual = 0;

  bool _isLoading = true;
  String? _error;
  
  // Datos reales traídos del backend
  Map<String, List<Map<String, dynamic>>> _horario = {
    'Lunes': [],
    'Martes': [],
    'Miércoles': [],
    'Jueves': [],
    'Viernes': []
  };

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _diaActual = (now.weekday - 1).clamp(0, 4);
    _cargarHorario();
  }

  Future<void> _cargarHorario() async {
    try {
      final res = await ApiService.get(AppConstants.horarioEndpoint);
      setState(() {
        _isLoading = false;
        // Mapear los datos de la API a nuestro tipo. Color viene en hex.
        if (res is Map) {
          res.forEach((dia, clasesList) {
            final classes = (clasesList as List).map((c) {
              Color parsedColor = AppTheme.accentPurple;
              if (c['color'] != null) {
                String hex = c['color'].toString().replaceAll('#', '');
                if (hex.length == 6) hex = 'FF$hex';
                parsedColor = Color(int.parse(hex, radix: 16));
              }
              return {
                'hora': c['hora'],
                'materia': c['materia'],
                'maestro': c['maestro'],
                'aula': c['aula'],
                'color': parsedColor,
              };
            }).toList();
            _horario[dia] = classes;
          });
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final clasesDelDia = _horario[_dias[_diaActual]] ?? [];

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
                        'Mi Horario',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.calendar_month, color: Colors.white),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Selector de días ────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            color: Colors.white,
            child: Row(
              children: List.generate(_dias.length, (i) {
                final isSelected = i == _diaActual;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _diaActual = i),
                    child: Column(
                      children: [
                        Text(
                          _dias[i].substring(0, 3),
                          style: TextStyle(
                            color: isSelected
                                ? AppTheme.accentPurple
                                : AppTheme.textGray,
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.accentPurple
                                : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${i + 1}',
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : AppTheme.textGray,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),

          const Divider(height: 1),

          // ── Título del día ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  _dias[_diaActual],
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                const Spacer(),
                Text(
                  '${clasesDelDia.length} clases',
                  style: TextStyle(color: AppTheme.textGray, fontSize: 13),
                ),
              ],
            ),
          ),

          // ── Lista de clases del día ─────────────────────────
          Expanded(
            child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                   ? Center(child: Text('Error: $_error', style: const TextStyle(color: AppTheme.accentRed)))
                   : clasesDelDia.isEmpty 
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.event_busy, size: 64, color: AppTheme.borderLight),
                              SizedBox(height: 16),
                              Text('No tienes clases este día', style: TextStyle(color: AppTheme.textGray)),
                            ],
                          ),
                        )
                      : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: clasesDelDia.length,
              itemBuilder: (context, index) {
                final clase = clasesDelDia[index];
                final isReceso = clase['materia'] == 'RECESO';

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Línea de tiempo
                      Column(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: clase['color'] as Color,
                            ),
                          ),
                          if (index < clasesDelDia.length - 1)
                            Container(
                              width: 2,
                              height: isReceso ? 40 : 60,
                              color: Colors.grey.shade300,
                            ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      // Contenido de la clase
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isReceso
                                ? AppTheme.accentGreen.withValues(alpha: 0.1)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: (clase['color'] as Color).withValues(alpha: 0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    isReceso ? Icons.coffee : Icons.class_,
                                    size: 16,
                                    color: clase['color'] as Color,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    clase['hora'] as String,
                                    style: TextStyle(
                                      color: AppTheme.textGray,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                clase['materia'] as String,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: isReceso ? 14 : 15,
                                  color: clase['color'] as Color,
                                ),
                              ),
                              if (!isReceso) ...[
                                const SizedBox(height: 2),
                                Text(
                                  '${clase['maestro']}  ·  ${clase['aula']}',
                                  style: TextStyle(
                                    color: AppTheme.textGray,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ],
                          ),
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
}
