import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/api_service.dart';
import '../../core/constants/app_constants.dart';

class AdminResenasTab extends StatefulWidget {
  const AdminResenasTab({super.key});

  @override
  State<AdminResenasTab> createState() => _AdminResenasTabState();
}

class _AdminResenasTabState extends State<AdminResenasTab> {
  bool _isLoading = true;
  String? _error;
  List<dynamic> _maestros = [];
  Map<String, dynamic>? _maestroSeleccionado;
  List<dynamic> _resenas = [];
  bool _isLoadingResenas = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadMaestros();
  }

  Future<void> _loadMaestros() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final res = await ApiService.get(AppConstants.maestrosEndpoint);
      if (res is List) {
        setState(() {
          _maestros = res;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _seleccionarMaestro(Map<String, dynamic> m) async {
    setState(() { _maestroSeleccionado = m; _isLoadingResenas = true; });
    try {
      final mId = m['id'] ?? m['_id'];
      final url = '/api/admin/maestros/$mId/opiniones';
      final res = await ApiService.get(url);
      if (res is List) {
        setState(() { _resenas = res; _isLoadingResenas = false; });
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      setState(() => _isLoadingResenas = false);
    }
  }

  Future<void> _borrarOpinion(String opId) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Reseña'),
        content: const Text('¿Estás seguro de que quieres borrar este comentario permanentemente?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentRed),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      )
    );

    if (confirmar == true && mounted) {
      try {
        await ApiService.deleteAuth('/api/admin/opiniones/$opId');
        if (_maestroSeleccionado != null) {
          _seleccionarMaestro(_maestroSeleccionado!); // Recargar reseñas
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text('Error: $_error'));

    if (_maestroSeleccionado == null) {
      final filteredMaestros = _maestros.where((m) {
        final query = _searchQuery.toLowerCase();
        final name = (m['username'] ?? '').toString().toLowerCase();
        return name.contains(query);
      }).toList();

      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar profesor...',
                prefixIcon: const Icon(Icons.search, color: AppTheme.accentPurple),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
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
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text('Selecciona a un profesor para auditar sus reseñas por los alumnos.',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textGray)),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: filteredMaestros.isEmpty
              ? const Center(child: Text('No se encontraron profesores.'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredMaestros.length,
                  itemBuilder: (ctx, i) {
                    final maestro = filteredMaestros[i];
                    final rating = maestro['rating'] ?? 0.0;
                    return Card(
                      child: ListTile(
                        leading: const CircleAvatar(backgroundColor: AppTheme.accentPurple, child: Icon(Icons.school, color: Colors.white)),
                        title: Text(maestro['username'] ?? 'Profesor'),
                        subtitle: Text('Promedio actual: $rating'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () => _seleccionarMaestro(maestro),
                      ),
                    );
                  },
                ),
          )
        ],
      );
    }

    return Column(
      children: [
        ListTile(
          tileColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => setState(() => _maestroSeleccionado = null),
          ),
          title: Text('Reseñas de ${_maestroSeleccionado!['username']}', style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        const Divider(height: 1),
        Expanded(
          child: _isLoadingResenas
            ? const Center(child: CircularProgressIndicator())
            : _resenas.isEmpty
              ? const Center(child: Text('No hay reseñas para este maestro.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _resenas.length,
                  itemBuilder: (ctx, i) {
                    final op = _resenas[i];
                    final opId = op['id'] ?? op['_id'];
                    final calif = op['calificacion'] ?? 0;
                    final autor = op['alumno_nombre'] ?? 'Anónimo';
                    final comentario = op['comentario'] ?? '';

                    return Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.person, color: AppTheme.textGray, size: 18),
                                const SizedBox(width: 6),
                                Text(autor, style: const TextStyle(fontWeight: FontWeight.bold)),
                                const Spacer(),
                                Row(
                                  children: List.generate(5, (index) => Icon(
                                    index < calif ? Icons.star : Icons.star_border,
                                    color: const Color(0xFFF59E0B),
                                    size: 16,
                                  )),
                                ),
                              ],
                            ),
                            if (comentario.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(comentario, style: const TextStyle(color: Colors.black87)),
                            ],
                            const SizedBox(height: 6),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                style: TextButton.styleFrom(foregroundColor: AppTheme.accentRed),
                                onPressed: () => _borrarOpinion(opId),
                                icon: const Icon(Icons.delete, size: 16),
                                label: const Text('Eliminar esta opinión')
                              )
                            )
                          ],
                        ),
                      )
                    );
                  },
              )
        )
      ],
    );
  }
}
