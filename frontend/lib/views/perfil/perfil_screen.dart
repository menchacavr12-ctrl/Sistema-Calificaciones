import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/api_service.dart';
import '../../core/constants/app_constants.dart';
import '../../controllers/auth_controller.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isUploading = false;
  Map<String, dynamic>? _user;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _fotoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarPerfil();
  }

  Future<void> _cargarPerfil() async {
    try {
      final res = await ApiService.get(AppConstants.profileEndpoint);
      setState(() {
        _user = res;
        _nameController.text = _user?['full_name'] ?? '';
        _fotoController.text = _user?['profile_picture'] ?? '';
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.accentRed),
        );
      }
    }
  }

  Future<void> _guardarPerfil() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      await ApiService.put(
        AppConstants.profileEndpoint,
        {
          'full_name': _nameController.text.trim(),
          'profile_picture': _fotoController.text.trim().isNotEmpty ? _fotoController.text.trim() : null,
        },
      );
      if (mounted) {
        ApiService.get(AppConstants.profileEndpoint).then((me) async {
          await ApiService.saveUser(me);
          if (mounted) Provider.of<AuthController>(context, listen: false).checkSession();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil guardado exitosamente'), backgroundColor: AppTheme.accentGreen),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.accentRed),
        );
      }
    } finally {
      setState(() {
        _isSaving = false;
        if (_user != null) {
          _user!['profile_picture'] = _fotoController.text.trim();
        }
      });
    }
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) {
      setState(() => _isUploading = true);
      final bytes = await pickedFile.readAsBytes();
      final scaffoldMsg = ScaffoldMessenger.of(context);

      try {
        final res = await ApiService.uploadFileAuth('/api/usuarios/me/foto', bytes.toList(), pickedFile.name);
        if (res['profile_picture'] != null) {
          setState(() {
            _fotoController.text = res['profile_picture'];
          });
          if (mounted) {
            ApiService.get(AppConstants.profileEndpoint).then((me) async {
              await ApiService.saveUser(me);
              if (mounted) Provider.of<AuthController>(context, listen: false).checkSession();
            });
          }
          scaffoldMsg.showSnackBar(
            const SnackBar(content: Text('Foto de perfil actualizada'), backgroundColor: AppTheme.accentGreen),
          );
        }
      } catch (e) {
         scaffoldMsg.showSnackBar(
           SnackBar(content: Text('Error al subir: $e'), backgroundColor: AppTheme.accentRed),
         );
      } finally {
        if (mounted) setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Mi Perfil', style: TextStyle(color: Colors.white)),
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: headerGradient)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: AppTheme.borderLight,
                          backgroundImage: (_fotoController.text.trim().isNotEmpty)
                              ? NetworkImage(_fotoController.text.trim())
                              : null,
                          child: (_fotoController.text.trim().isEmpty)
                              ? const Icon(Icons.person, size: 60, color: AppTheme.textGray)
                              : null,
                        ),
                        if (_isUploading)
                          const CircularProgressIndicator(color: AppTheme.accentPurple),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _isUploading ? null : _pickAndUploadImage,
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: AppTheme.primaryDark,
                              child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre Completo',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (v) => v!.trim().isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 20),

                    TextFormField(
                      initialValue: _user?['email'] ?? '',
                      enabled: false,
                      decoration: const InputDecoration(
                        labelText: 'Correo',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      initialValue: _user?['role']?.toString().toUpperCase() ?? '',
                      enabled: false,
                      decoration: const InputDecoration(
                        labelText: 'Rol',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.badge),
                      ),
                    ),

                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _guardarPerfil,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryDark,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isSaving
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Guardar Cambios', style: TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
