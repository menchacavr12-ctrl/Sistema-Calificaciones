import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/api_service.dart';

class UnirseClaseScreen extends StatefulWidget {
  const UnirseClaseScreen({super.key});

  @override
  State<UnirseClaseScreen> createState() => _UnirseClaseScreenState();
}

class _UnirseClaseScreenState extends State<UnirseClaseScreen> {
  final _codeController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  bool _success = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _unirseClase() async {
    if (_codeController.text.trim().isEmpty) {
      setState(() => _error = 'Ingresa un código de clase');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await ApiService.postAuth('/api/clases/unirse', {
        'codigo_acceso': _codeController.text.trim(),
      });
      setState(() {
        _success = true;
        _isLoading = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _error = e.message;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error de conexión. Verifica que el backend esté activo.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                        'Unirse a una Clase',
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

          // ── Contenido ───────────────────────────────────────
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: _success ? _buildSuccess() : _buildForm(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Ícono grande
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.accentPurple.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.laptop_chromebook,
            size: 60,
            color: AppTheme.accentPurple,
          ),
        ),
        const SizedBox(height: 24),

        const Text(
          'Ingresa el código de la clase',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tu maestro te proporcionará un código\núnico para unirte a su clase',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppTheme.textGray, fontSize: 13),
        ),
        const SizedBox(height: 30),

        // Campo de código
        TextField(
          controller: _codeController,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppTheme.textDark,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 6,
          ),
          decoration: InputDecoration(
            hintText: 'ABC123',
            hintStyle: TextStyle(
              color: Colors.grey.shade300,
              fontSize: 28,
              letterSpacing: 6,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppTheme.accentPurple, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppTheme.accentPurple, width: 2),
            ),
          ),
          textCapitalization: TextCapitalization.characters,
        ),
        const SizedBox(height: 12),

        if (_error != null)
          Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppTheme.accentRed.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline,
                    color: AppTheme.accentRed, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _error!,
                    style: const TextStyle(
                        color: AppTheme.accentRed, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 8),

        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _unirseClase,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentPurple,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25)),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 22, height: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5))
                : const Text(
                    'Unirse a la Clase',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccess() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: AppTheme.accentGreen,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, size: 60, color: Colors.white),
        ),
        const SizedBox(height: 24),
        const Text(
          '¡Te uniste exitosamente!',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppTheme.accentGreen,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Ya puedes ver esta clase en tu panel',
          style: TextStyle(color: AppTheme.textGray),
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentGreen,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25)),
            ),
            child: const Text(
              'Volver al Inicio',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
