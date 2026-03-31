import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/api_service.dart';
import '../../core/constants/app_constants.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';

class AdminUsuariosTab extends StatefulWidget {
  const AdminUsuariosTab({super.key});

  @override
  State<AdminUsuariosTab> createState() => _AdminUsuariosTabState();
}

class _AdminUsuariosTabState extends State<AdminUsuariosTab> {
  bool _isLoading = true;
  String? _error;
  List<dynamic> _usuarios = [];
  String _filtroRol = 'Todos';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadUsuarios();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsuarios() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final res = await ApiService.get(AppConstants.adminUsuariosEndpoint);
      if (res is List) {
        setState(() {
          _usuarios = res;
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

  void _confirmarCambioEstado(String userId, String currentStatus, String username) {
    final esBaja = currentStatus == 'activo';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(esBaja ? 'Dar de baja' : 'Reactivar'),
        content: Text(esBaja 
          ? '¿Seguro que quieres dar de baja a $username? Ya no podrá loguearse ni aparecerá en listas.'
          : '¿Seguro que quieres reactivar a $username?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: esBaja ? AppTheme.accentRed : AppTheme.accentGreen),
            onPressed: () async {
              Navigator.pop(ctx);
              final nuevo = esBaja ? 'inactivo' : 'activo';
              try {
                await ApiService.put('${AppConstants.adminUsuariosEndpoint}/$userId/status?status=$nuevo', {});
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Usuario ${esBaja ? "desactivado" : "reactivado"} con éxito'),
                      backgroundColor: AppTheme.accentGreen,
                    ),
                  );
                }
                _loadUsuarios();
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al cambiar estado: $e'),
                      backgroundColor: AppTheme.accentRed,
                    ),
                  );
                }
              }
            },
            child: const Text('Confirmar', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  void _promoverUsuaro(String userId, String currentRole, String username) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cambiar Rol (Súper Admin)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Hacer Alumno'),
              onTap: () => _efectuarPromocion(ctx, userId, 'alumno'),
            ),
            ListTile(
              title: const Text('Hacer Maestro'),
              onTap: () => _efectuarPromocion(ctx, userId, 'maestro'),
            ),
            ListTile(
              title: const Text('Hacer Admin'),
              onTap: () => _efectuarPromocion(ctx, userId, 'admin'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _efectuarPromocion(BuildContext ctx, String userId, String nuevoRol) async {
    Navigator.pop(ctx);
    try {
      await ApiService.put('${AppConstants.adminUsuariosEndpoint}/$userId/role?role=$nuevoRol', {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Rol de usuario actualizado a $nuevoRol'),
            backgroundColor: AppTheme.accentGreen,
          ),
        );
      }
      _loadUsuarios();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cambiar rol: $e'),
            backgroundColor: AppTheme.accentRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final miUser = context.watch<AuthController>().user;
    final esSuperAdmin = miUser?.role == 'super_admin';

    // Si el usuario ya no existe (logout en curso), no mostramos errores, simplemente esperamos la navegación
    if (miUser == null) return const Center(child: CircularProgressIndicator());

    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text('Error: $_error'));

    // --- FILTRADO ---
    List<dynamic> filtrados = _usuarios;
    
    // Filtro por Rol
    if (_filtroRol != 'Todos') {
      filtrados = filtrados.where((u) => u['role'] == _filtroRol.toLowerCase()).toList();
    }
    
    // Filtro por Búsqueda
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtrados = filtrados.where((u) {
        final nom = (u['username'] ?? '').toString().toLowerCase();
        final email = (u['email'] ?? '').toString().toLowerCase();
        return nom.contains(query) || email.contains(query);
      }).toList();
    }

    return Column(
      children: [
        // BUSCADOR
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar por nombre o correo...',
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

        Padding(
          padding: const EdgeInsets.all(12),
          child: SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'Todos', label: Text('Todos')),
              ButtonSegment(value: 'Alumno', label: Text('Alumnos')),
              ButtonSegment(value: 'Maestro', label: Text('Maestros')),
            ],
            selected: {_filtroRol},
            onSelectionChanged: (set) => setState(() => _filtroRol = set.first),
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                if (states.contains(WidgetState.selected)) return AppTheme.accentPurple.withValues(alpha: 0.2);
                return Colors.transparent;
              }),
            ),
          ),
        ),

        Expanded(
          child: filtrados.isEmpty 
            ? const Center(child: Text('No se encontraron usuarios.', style: TextStyle(color: AppTheme.textGray)))
            : ListView.builder(
                itemCount: filtrados.length,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (context, index) {
                  final user = filtrados[index];
                  final nom = user['username'] ?? 'No Name';
                  final email = user['email'] ?? '';
                  final rol = user['role'] ?? 'alumno';
                  final estado = user['status'] ?? 'activo';
                  final id = user['id'] ?? user['_id'];

                  final isMe = id == miUser.id;
                  final canEdit = !isMe && (esSuperAdmin || (rol != 'admin' && rol != 'super_admin'));

                  Color rolColor = Colors.grey;
                  if (rol == 'alumno') rolColor = AppTheme.colorAlumno;
                  if (rol == 'maestro') rolColor = AppTheme.colorMaestro;
                  if (rol == 'admin' || rol == 'super_admin') rolColor = AppTheme.colorAdmin;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: rolColor.withValues(alpha: 0.2),
                        child: Icon(
                          rol == 'maestro' ? Icons.school : (rol == 'alumno' ? Icons.person : Icons.admin_panel_settings),
                          color: rolColor,
                        ),
                      ),
                      title: Row(
                        children: [
                          Expanded(child: Text(nom, style: const TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                          if (estado != 'activo')
                            const Padding(
                              padding: EdgeInsets.only(left: 8.0),
                              child: Text('(Inactivo)', style: TextStyle(color: AppTheme.accentRed, fontSize: 12, fontWeight: FontWeight.bold)),
                            )
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(email, style: const TextStyle(fontSize: 10, color: AppTheme.textGray)),
                          Text(rol.toString().toUpperCase(), style: TextStyle(color: rolColor, fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      trailing: canEdit
                          ? PopupMenuButton<String>(
                              onSelected: (val) {
                                if (val == 'status') _confirmarCambioEstado(id, estado, nom);
                                if (val == 'role') _promoverUsuaro(id, rol, nom);
                              },
                              itemBuilder: (ctx) => [
                                PopupMenuItem(
                                  value: 'status',
                                  child: Text(estado == 'activo' ? 'Dar de baja' : 'Reactivar'),
                                ),
                                if (esSuperAdmin)
                                  const PopupMenuItem(
                                    value: 'role',
                                    child: Text('Cambiar Rol'),
                                  ),
                              ],
                            )
                          : null,
                    ),
                  );
                },
              ),
        ),
      ],
    );

  }
}
