import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/api_service.dart';
import '../../core/constants/app_constants.dart';

import 'admin_chat_screen.dart';

class AdminAyudaTab extends StatefulWidget {
  const AdminAyudaTab({super.key});

  @override
  State<AdminAyudaTab> createState() => _AdminAyudaTabState();
}

class _AdminAyudaTabState extends State<AdminAyudaTab> {
  bool _isLoading = true;
  String? _error;
  List<dynamic> _alumnosChat = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  Future<void> _loadChats() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final res = await ApiService.get(AppConstants.adminChatListaEndpoint);
      if (res is List) {
        setState(() {
          _alumnosChat = res;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text('Error: $_error'));

    if (_alumnosChat.isEmpty) {
      return const Center(child: Text('No hay alumnos registrados.', style: TextStyle(color: AppTheme.textGray)));
    }

    final filtered = _alumnosChat.where((a) {
      final query = _searchQuery.toLowerCase();
      final nom = (a['usuario_nombre'] ?? '').toString().toLowerCase();
      final email = (a['usuario_email'] ?? '').toString().toLowerCase();
      return nom.contains(query) || email.contains(query);
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Buscar alumno...',
              prefixIcon: const Icon(Icons.search, color: AppTheme.accentPurple),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
            onChanged: (val) => setState(() => _searchQuery = val),
          ),
        ),

        Expanded(
          child: filtered.isEmpty
            ? const Center(child: Text('No se encontraron chats.', style: TextStyle(color: AppTheme.textGray)))
            : ListView.builder(
                itemCount: filtered.length,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (context, index) {
                  final alumno = filtered[index];
                  final num unreads = alumno['unread_count'] ?? 0;
                  final hasUnread = unreads > 0;

                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: Stack(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppTheme.accentPurple.withValues(alpha: 0.1),
                            child: const Icon(Icons.person, color: AppTheme.accentPurple),
                          ),
                          if (hasUnread)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  unreads.toString(),
                                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            )
                        ],
                      ),
                      title: Text(
                        alumno['usuario_nombre'] ?? 'Desconocido',
                        style: TextStyle(fontWeight: hasUnread ? FontWeight.bold : FontWeight.w500)
                      ),
                      subtitle: Text(
                        alumno['usuario_email'] ?? '',
                        style: TextStyle(color: hasUnread ? Colors.black87 : AppTheme.textGray),
                      ),
                      trailing: const Icon(Icons.chevron_right, color: AppTheme.textGray),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AdminChatScreen(
                              alumnoId: alumno['usuario_id'],
                              alumnoNombre: alumno['usuario_nombre'] ?? 'Alumno',
                            )
                          )
                        ).then((_) => _loadChats()); // Recargar al volver para actualizar conteos
                      },
                    ),
                  );
                },
              ),
        ),
      ],
    );

  }
}
