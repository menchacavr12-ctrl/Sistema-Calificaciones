import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http_parser/http_parser.dart';
import '../constants/app_constants.dart';

class ApiService {
  static const _storage = FlutterSecureStorage();

  static Future<String?> _getToken() async {
    return await _storage.read(key: AppConstants.tokenKey);
  }

  static Future<Map<String, String>> _getHeaders({bool auth = false}) async {
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await _getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final url = Uri.parse('${AppConstants.baseUrl}$endpoint');
    final response = await http.post(
      url,
      headers: await _getHeaders(),
      body: jsonEncode(body),
    ).timeout(const Duration(seconds: 60), onTimeout: () {
      throw ApiException('Tiempo de espera agotado', 408);
    });
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> postAuth(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final url = Uri.parse('${AppConstants.baseUrl}$endpoint');
    final response = await http.post(
      url,
      headers: await _getHeaders(auth: true),
      body: jsonEncode(body),
    ).timeout(const Duration(seconds: 60), onTimeout: () {
      throw ApiException('Tiempo de espera agotado', 408);
    });
    return _handleResponse(response);
  }

  static Future<dynamic> get(String endpoint) async {
    final url = Uri.parse('${AppConstants.baseUrl}$endpoint');
    final response = await http.get(
      url,
      headers: await _getHeaders(auth: true),
    ).timeout(const Duration(seconds: 60), onTimeout: () {
      throw ApiException('Tiempo de espera agotado', 408);
    });
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final url = Uri.parse('${AppConstants.baseUrl}$endpoint');
    final response = await http.put(
      url,
      headers: await _getHeaders(auth: true),
      body: jsonEncode(body),
    ).timeout(const Duration(seconds: 60), onTimeout: () {
      throw ApiException('Tiempo de espera agotado', 408);
    });
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> deleteAuth(String endpoint) async {
    final url = Uri.parse('${AppConstants.baseUrl}$endpoint');
    final response = await http.delete(
      url,
      headers: await _getHeaders(auth: true),
    ).timeout(const Duration(seconds: 60), onTimeout: () {
      throw ApiException('Tiempo de espera agotado', 408);
    });
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> uploadFileAuth(
      String endpoint, List<int> bytes, String filename) async {
    final url = Uri.parse('${AppConstants.baseUrl}$endpoint');
    var request = http.MultipartRequest('POST', url);
    final token = await _getToken();
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: filename,
        contentType: MediaType.parse(_getMimeType(filename)),
      ),
    );

    final streamedResponse = await request.send().timeout(const Duration(seconds: 25), onTimeout: () {
      throw ApiException('Tiempo de subida agotado', 408);
    });
    final response = await http.Response.fromStream(streamedResponse);
    return _handleResponse(response);
  }

  static Future<void> saveToken(String token) async {
    await _storage.write(key: AppConstants.tokenKey, value: token);
  }

  static Future<void> saveUser(Map<String, dynamic> user) async {
    await _storage.write(key: AppConstants.userKey, value: jsonEncode(user));
  }

  static Future<Map<String, dynamic>?> getSavedUser() async {
    final data = await _storage.read(key: AppConstants.userKey);
    if (data != null) return jsonDecode(data);
    return null;
  }

  static Future<void> clearSession() async {
    await _storage.deleteAll();
  }

  static dynamic _handleResponse(http.Response response) {
    final decoded = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    } else {
      final detail = decoded['detail'] ?? 'Error desconocido';
      throw ApiException(detail.toString(), response.statusCode);
    }
  }

  static String _getMimeType(String filename) {
    if (filename.toLowerCase().endsWith('.png')) return 'image/png';
    if (filename.toLowerCase().endsWith('.gif')) return 'image/gif';
    if (filename.toLowerCase().endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  ApiException(this.message, this.statusCode);

  @override
  String toString() => message;
}
