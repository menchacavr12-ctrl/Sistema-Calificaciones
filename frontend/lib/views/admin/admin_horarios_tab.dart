import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/api_service.dart';
import '../../core/constants/app_constants.dart';

class AdminHorariosTab extends StatefulWidget {
  const AdminHorariosTab({super.key});

  @override
  State<AdminHorariosTab> createState() => _AdminHorariosTabState();
}

class _AdminHorariosTabState extends State<AdminHorariosTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  bool _isLoadingUsuarios = true;
  String? _error;
  List<dynamic> _usuarios = [];
  Map<String, dynamic>? _selectedUser;
  String _searchIndividual = '';
  String _searchGrupal = '';

  bool _isLoadingHorario = false;

  Map<String, List<dynamic>> _horario = {
    'Lunes': [], 'Martes': [], 'Miércoles': [], 'Jueves': [], 'Viernes': []
  };

  List<dynamic> _alumnosGrupo = [];
  Set<String> _selectedAlumnosIds = {};
  bool _isSendingGrupo = false;
  final List<String> _opcionesDias = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUsuarios();
  }

  Future<void> _loadUsuarios() async {
    setState(() { _isLoadingUsuarios = true; _error = null; });
    try {
      final res = await ApiService.get(AppConstants.adminUsuariosEndpoint);
      if (res is List) {
        setState(() {
          _usuarios = res.where((u) => u['role'] == 'alumno' || u['role'] == 'maestro').toList();
          _alumnosGrupo = res.where((u) => u['role'] == 'alumno').toList();
          _isLoadingUsuarios = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _isLoadingUsuarios = false; });
    }
  }

  Future<void> _verHorario(Map<String, dynamic> user) async {
    setState(() { _selectedUser = user; _isLoadingHorario = true; });
    try {
      final userId = user['id'] ?? user['_id'];
      final res = await ApiService.get('/api/horarios/usuario/$userId');
      if (res is Map) {
        setState(() {
          _horario = {
            'Lunes': res['Lunes'] ?? [],
            'Martes': res['Martes'] ?? [],
            'Miércoles': res['Miércoles'] ?? [],
            'Jueves': res['Jueves'] ?? [],
            'Viernes': res['Viernes'] ?? [],
          };
          _isLoadingHorario = false;
        });
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      setState(() => _isLoadingHorario = false);
    }
  }

  void _agregarBloque() {
    if (_selectedUser == null) return;
    final userId = _selectedUser!['id'] ?? _selectedUser!['_id'];

    String selectedDia = 'Lunes';
    final horaCtrl = TextEditingController(text: '08:00 - 09:00');
    final materiaCtrl = TextEditingController();
    final maestroCtrl = TextEditingController();
    final aulaCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Agregar Bloque'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedDia,
                decoration: const InputDecoration(labelText: 'Día de la semana'),
                items: _opcionesDias.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                onChanged: (v) => selectedDia = v ?? 'Lunes',
              ),
              TextField(controller: horaCtrl, decoration: const InputDecoration(labelText: 'Hora')),
              TextField(controller: materiaCtrl, decoration: const InputDecoration(labelText: 'Materia o Título')),
              TextField(controller: maestroCtrl, decoration: const InputDecoration(labelText: 'Maestro a cargo')),
              TextField(controller: aulaCtrl, decoration: const InputDecoration(labelText: 'Aula / Ubicación')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ApiService.postAuth('/api/horarios/usuario/$userId', {
                  'dia': selectedDia,
                  'hora': horaCtrl.text.trim(),
                  'materia': materiaCtrl.text.trim(),
                  'maestro': maestroCtrl.text.trim(),
                  'aula': aulaCtrl.text.trim(),
                  'color': '#1E3A8A' // Azul fijo para el admin
                });
                _verHorario(_selectedUser!);
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: const Text('Guardar'),
          )
        ],
      )
    );
  }

  void _borrarBloque(String blockId) async {
    try {
      await ApiService.deleteAuth('/api/horarios/$blockId');
      if (_selectedUser != null) _verHorario(_selectedUser!);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _mostrarFormularioGrupo() {
    if (_selectedAlumnosIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecciona al menos un alumno')));
      return;
    }

    String selectedDia = 'Lunes';
    final horaCtrl = TextEditingController(text: '08:00 - 09:00');
    final materiaCtrl = TextEditingController();
    final maestroCtrl = TextEditingController();
    final aulaCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Añadir a ${_selectedAlumnosIds.length} alumnos'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedDia,
                decoration: const InputDecoration(labelText: 'Día de la semana'),
                items: _opcionesDias.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                onChanged: (v) => selectedDia = v ?? 'Lunes',
              ),
              TextField(controller: horaCtrl, decoration: const InputDecoration(labelText: 'Hora')),
              TextField(controller: materiaCtrl, decoration: const InputDecoration(labelText: 'Materia o Título')),
              TextField(controller: maestroCtrl, decoration: const InputDecoration(labelText: 'Maestro a cargo')),
              TextField(controller: aulaCtrl, decoration: const InputDecoration(labelText: 'Aula / Ubicación')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentGreen),
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _isSendingGrupo = true);
              try {
                await ApiService.postAuth(AppConstants.adminHorarioGrupoEndpoint, {
                  'alumnos_ids': _selectedAlumnosIds.toList(),
                  'dia': selectedDia,
                  'hora': horaCtrl.text.trim(),
                  'materia': materiaCtrl.text.trim(),
                  'maestro': maestroCtrl.text.trim(),
                  'aula': aulaCtrl.text.trim(),
                  'color': '#7C3AED'
                });
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Horario grupal aplicado exitosamente'), backgroundColor: AppTheme.accentGreen));
                setState(() => _selectedAlumnosIds.clear());
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              } finally {
                if (mounted) setState(() => _isSendingGrupo = false);
              }
            },
            child: const Text('Aplicar a Todo el Grupo'),
          )
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingUsuarios) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text('Error: $_error'));

    return Column(
      children: [
        TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryDark,
          unselectedLabelColor: AppTheme.textGray,
          indicatorColor: AppTheme.primaryDark,
          tabs: const [
            Tab(text: 'Individual / Editar'),
            Tab(text: 'Asignación Grupal'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildPestanaIndividual(),
              _buildPestanaGrupal(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPestanaIndividual() {
    if (_selectedUser == null) {
      final filtered = _usuarios.where((u) {
        final q = _searchIndividual.toLowerCase();
        final name = (u['username'] ?? '').toString().toLowerCase();
        return name.contains(q);
      }).toList();

      return Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text('Selecciona a un alumno o maestro para gestionar su horario.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar por nombre...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (v) => setState(() => _searchIndividual = v),
            ),
          ),
          Expanded(
            child: filtered.isEmpty
              ? const Center(child: Text('No hay coincidencias.'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  itemBuilder: (ctx, i) {
                    final user = filtered[i];
                    return Card(
                      child: ListTile(
                        leading: Icon(user['role'] == 'maestro' ? Icons.school : Icons.person, color: AppTheme.accentPurple),
                        title: Text(user['username'] ?? ''),
                        subtitle: Text(user['role']?.toString().toUpperCase() ?? ''),
                        trailing: const Icon(Icons.calendar_month),
                        onTap: () => _verHorario(user),
                      ),
                    );
                  },
                ),
          )
        ],
      );
    }

    final nombreStr = _selectedUser!['username'] ?? '';

    return Column(
      children: [
        ListTile(
          tileColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => setState(() => _selectedUser = null),
          ),
          title: Text('Horario de $nombreStr', style: const TextStyle(fontWeight: FontWeight.bold)),
          trailing: ElevatedButton.icon(
            onPressed: _agregarBloque,
            icon: const Icon(Icons.add, size: 16, color: Colors.white),
            label: const Text('Añadir', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentGreen),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: _isLoadingHorario
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: _horario.entries.map((entry) {
                   final dia = entry.key;
                   final clases = entry.value;
                   if (clases.isEmpty) return const SizedBox.shrink();

                   return Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Padding(
                         padding: const EdgeInsets.symmetric(vertical: 8),
                         child: Text(dia, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryDark)),
                       ),
                       ...clases.map((c) {
                         return Card(
                           margin: const EdgeInsets.only(bottom: 8),
                           child: ListTile(
                             title: Text('${c['hora']} - ${c['materia']}'),
                             subtitle: Text('Prof: ${c['maestro']} | Aula: ${c['aula']}'),
                             trailing: IconButton(
                               icon: const Icon(Icons.delete, color: AppTheme.accentRed),
                               onPressed: () => _borrarBloque(c['id'] ?? c['_id']),
                             ),
                           ),
                         );
                       })
                     ],
                   );
                }).toList(),
            ),
        ),
      ],
    );
  }

  Widget _buildPestanaGrupal() {
    final filtered = _alumnosGrupo.where((a) {
      final q = _searchGrupal.toLowerCase();
      final name = (a['username'] ?? '').toString().toLowerCase();
      return name.contains(q);
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Seleccionados: ${_selectedAlumnosIds.length}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
              ),
              ElevatedButton.icon(
                onPressed: _selectedAlumnosIds.isNotEmpty && !_isSendingGrupo ? _mostrarFormularioGrupo : null,
                icon: const Icon(Icons.group_add, size: 18),
                label: const Text('Asignar Bloque'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentPurple,
                  foregroundColor: Colors.white
                ),
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Buscar alumno para el grupo...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: (v) => setState(() => _searchGrupal = v),
          ),
        ),
        const Divider(),
        if (_isSendingGrupo) const LinearProgressIndicator(),
        Expanded(
          child: filtered.isEmpty
            ? const Center(child: Text('No hay coincidencias.'))
            : ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final alumno = filtered[index];
                  final alumnoId = alumno['id'] ?? alumno['_id'];
                  final bool isSelected = _selectedAlumnosIds.contains(alumnoId);

                  return CheckboxListTile(
                    title: Text(alumno['username'] ?? ''),
                    subtitle: Text(alumno['email'] ?? ''),
                    value: isSelected,
                    activeColor: AppTheme.accentPurple,
                    onChanged: (bool? val) {
                      setState(() {
                        if (val == true) {
                          _selectedAlumnosIds.add(alumnoId);
                        } else {
                          _selectedAlumnosIds.remove(alumnoId);
                        }
                      });
                    },
                    secondary: const Icon(Icons.person, color: AppTheme.textGray),
                  );
                },
              ),
        )
      ],
    );
  }
}
