import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/api_service.dart';

class ResenaMaestroScreen extends StatefulWidget {
  final Map<String, dynamic> maestro;
  const ResenaMaestroScreen({super.key, required this.maestro});

  @override
  State<ResenaMaestroScreen> createState() => _ResenaMaestroScreenState();
}

class _ResenaMaestroScreenState extends State<ResenaMaestroScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _maestroDetalle;

  final TextEditingController _comentarioController = TextEditingController();
  int _miCalificacion = 0;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadDetalle();
  }

  Future<void> _loadDetalle() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiService.get('/api/usuarios/maestros/${widget.maestro['id'] ?? widget.maestro['_id']}');
      setState(() {
        _maestroDetalle = res;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _enviarResena() async {
    if (_miCalificacion == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona una calificación en estrellas.')),
      );
      return;
    }

    final scaffoldMsg = ScaffoldMessenger.of(context);
    setState(() => _isSubmitting = true);

    try {
      final maestroId = widget.maestro['id'] ?? widget.maestro['_id'];
      await ApiService.postAuth(
        '/api/usuarios/maestros/$maestroId/opinion',
        {
          'calificacion': _miCalificacion,
          'comentario': _comentarioController.text.trim(),
        },
      );

      if (mounted) {
        _comentarioController.clear();
        setState(() => _miCalificacion = 0);
        await _loadDetalle();
        scaffoldMsg.showSnackBar(
          const SnackBar(content: Text('Tu reseña ha sido guardada.'), backgroundColor: AppTheme.accentGreen),
        );
      }
    } catch (e) {
      if (mounted) {
        scaffoldMsg.showSnackBar(
          SnackBar(content: Text('Error al enviar reseña: $e'), backgroundColor: AppTheme.accentRed),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _maestroDetalle == null) {
      return Scaffold(
        appBar: AppBar(backgroundColor: AppTheme.primaryDark),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final datos = _maestroDetalle ?? widget.maestro;
    final profilePic = datos['profile_picture'];
    final username = datos['username'] ?? 'Maestro';
    final especialidad = datos['especialidad'] ?? '';
    final promedio = (datos['promedio_opinion'] ?? datos['rating'] ?? 0.0).toDouble();
    final total = datos['total_opiniones'] ?? 0;

    final opiniones = (datos['opiniones'] as List?) ?? [];

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Reseñas', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primaryDark,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: AppTheme.accentPurple.withValues(alpha: 0.15),
                      backgroundImage: (profilePic != null && profilePic.isNotEmpty)
                          ? NetworkImage(profilePic)
                          : null,
                      child: (profilePic == null || profilePic.isEmpty)
                          ? Text(
                              username[0].toUpperCase(),
                              style: const TextStyle(color: AppTheme.accentPurple, fontSize: 30, fontWeight: FontWeight.bold),
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(username, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(especialidad, style: const TextStyle(color: AppTheme.accentPurple, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Color(0xFFF59E0B), size: 20),
                              const SizedBox(width: 4),
                              Text(promedio.toStringAsFixed(1), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(width: 8),
                              Text('($total reseñas)', style: const TextStyle(color: AppTheme.textGray)),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Deja tu opinión anónima', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            index < _miCalificacion ? Icons.star : Icons.star_border,
                            color: const Color(0xFFF59E0B),
                            size: 32,
                          ),
                          onPressed: () {
                            setState(() => _miCalificacion = index + 1);
                          },
                        );
                      }),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _comentarioController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Describe tu experiencia con este docente...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _enviarResena,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentPurple,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                        ),
                        child: _isSubmitting
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Enviar Reseña', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Lo que dicen los alumnos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const SizedBox(height: 12),
            opiniones.isNotEmpty
            ? ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: opiniones.length,
                itemBuilder: (context, index) {
                  final op = opiniones[index];
                  final nota = (op['calificacion'] ?? 0).toInt();
                  final texto = op['comentario'] ?? '';
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: AppTheme.backgroundLight,
                        child: Icon(Icons.person, color: AppTheme.textGray),
                      ),
                      title: Row(
                        children: [
                          const Text('Alumno Anónimo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          const Spacer(),
                          Row(
                            children: List.generate(5, (sIndex) {
                              return Icon(
                                sIndex < nota ? Icons.star : Icons.star_border,
                                color: const Color(0xFFF59E0B),
                                size: 14,
                              );
                            }),
                          ),
                        ],
                      ),
                      subtitle: texto.isNotEmpty ? Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(texto, style: const TextStyle(fontSize: 13)),
                      ) : null,
                    ),
                  );
                },
              )
            : const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text('No hay reseñas aún. ¡Sé el primero!', style: TextStyle(color: AppTheme.textGray)),
                ),
              ),
          ],
        ),
      )
    );
  }
}
