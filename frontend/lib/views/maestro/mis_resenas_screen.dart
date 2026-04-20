import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/api_service.dart';

class MisResenasScreen extends StatefulWidget {
  const MisResenasScreen({super.key});

  @override
  State<MisResenasScreen> createState() => _MisResenasScreenState();
}

class _MisResenasScreenState extends State<MisResenasScreen> {
  bool _isLoading = true;
  String? _error;
  double _promedio = 0.0;
  int _total = 0;
  List<dynamic> _resenas = [];

  @override
  void initState() {
    super.initState();
    _loadResenas();
  }

  Future<void> _loadResenas() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiService.get('/api/usuarios/me/opiniones');
      setState(() {
        _promedio = (res['promedio'] ?? 0.0).toDouble();
        _total = (res['total'] ?? 0).toInt();
        _resenas = res['reseñas'] ?? [];
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Bandeja de Reseñas', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primaryDark,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error', style: const TextStyle(color: AppTheme.accentRed)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                        color: AppTheme.primaryDark,
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            children: [
                              const Text('Tu Calificación Promedio', style: TextStyle(color: Colors.white70, fontSize: 16)),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.star, color: Color(0xFFF59E0B), size: 40),
                                  const SizedBox(width: 8),
                                  Text(_promedio.toStringAsFixed(1), style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text('Basado en $_total reseñas', style: const TextStyle(color: Colors.white70, fontSize: 14)),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Reseñas de tus Alumnos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      ),
                      const SizedBox(height: 12),

                      _resenas.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Text('Los alumnos aún no te han calificado.', style: TextStyle(color: AppTheme.textGray)),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _resenas.length,
                          itemBuilder: (context, index) {
                            final op = _resenas[index];
                            final nota = (op['calificacion'] ?? 0).toInt();
                            final texto = op['comentario'] ?? '';
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const CircleAvatar(
                                          backgroundColor: AppTheme.backgroundLight,
                                          radius: 16,
                                          child: Icon(Icons.person, color: AppTheme.textGray, size: 20),
                                        ),
                                        const SizedBox(width: 8),
                                        const Text('Alumno Anónimo', style: TextStyle(fontWeight: FontWeight.bold)),
                                        const Spacer(),
                                        Row(
                                          children: List.generate(5, (sIndex) {
                                            return Icon(
                                              sIndex < nota ? Icons.star : Icons.star_border,
                                              color: const Color(0xFFF59E0B),
                                              size: 16,
                                            );
                                          }),
                                        ),
                                      ],
                                    ),
                                    if (texto.isNotEmpty) ...[
                                      const SizedBox(height: 12),
                                      const Divider(height: 1),
                                      const SizedBox(height: 12),
                                      Text(texto, style: const TextStyle(fontSize: 14)),
                                    ]
                                  ],
                                ),
                              ),
                            );
                          },
                        )
                    ],
                  ),
                ),
    );
  }
}
