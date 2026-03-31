import 'package:flutter/material.dart';
import '../core/services/api_service.dart';
import '../core/constants/app_constants.dart';
import '../models/user_model.dart';

class AuthController extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  // ── Verificar sesión guardada al abrir la app ─────────────────────────
  Future<bool> checkSession() async {
    try {
      final savedUser = await ApiService.getSavedUser();
      if (savedUser != null) {
        _user = UserModel.fromJson(savedUser);
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Error al verificar sesión: $e');
    }
    return false;
  }

  // ── REGISTRO ──────────────────────────────────────────────────────────
  Future<Map<String, dynamic>?> register({
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final result = await ApiService.post(AppConstants.registerEndpoint, {
        'username': username,
        'email': email,
        'password': password,
        'confirm_password': confirmPassword,
      });
      return result;
    } on ApiException catch (e) {
      _setError(e.message);
      return null;
    } catch (e) {
      _setError('Error de conexión con el servidor.');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // ── LOGIN ─────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>?> login({
    required String emailOrUsername,
    required String password,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final result = await ApiService.post(AppConstants.loginEndpoint, {
        'email_or_username': emailOrUsername,
        'password': password,
      });
      await _saveSession(result);
      return result;
    } on ApiException catch (e) {
      // Si el status es 403, significa que no está verificado (flujo antiguo) o bloqueado
      _setError(e.message);
      return null;
    } catch (e) {
      _setError('Error de conexión con el servidor.');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // ── CERRAR SESIÓN ─────────────────────────────────────────────────────
  Future<void> logout() async {
    await ApiService.clearSession();
    _user = null;
    notifyListeners();
  }

  // ── Guardar sesión ────────────────────────────────────────────────────
  Future<void> _saveSession(Map<String, dynamic> result) async {
    final token = result['access_token'];
    final userData = result['user'];
    await ApiService.saveToken(token);
    await ApiService.saveUser(userData);
    _user = UserModel.fromJson(userData);
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
