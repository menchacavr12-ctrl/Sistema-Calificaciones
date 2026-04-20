import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/api_service.dart';
import '../../core/constants/app_constants.dart';


class AdminChatScreen extends StatefulWidget {
  final String alumnoId;
  final String alumnoNombre;

  const AdminChatScreen({super.key, required this.alumnoId, required this.alumnoNombre});

  @override
  State<AdminChatScreen> createState() => _AdminChatScreenState();
}

class _AdminChatScreenState extends State<AdminChatScreen> {
  bool _isLoading = true;
  String? _error;
  List<dynamic> _mensajes = [];
  final TextEditingController _msgController = TextEditingController();
  WebSocketChannel? _channel;

  @override
  void initState() {
    super.initState();
    _loadHistorial().then((_) => _conectarWebSocket());
  }

  void _conectarWebSocket() {
    final authController = Provider.of<AuthController>(context, listen: false);
    final adminId = authController.user?.id;
    final adminRole = authController.user?.role;
    if (adminId == null) return;
    
    final wsUrl = Uri.parse('${AppConstants.wsBaseUrl}/api/ayuda/ws/admin/${widget.alumnoId}?admin_id=$adminId&rol=$adminRole');
    _channel = WebSocketChannel.connect(wsUrl);
    
    _channel!.stream.listen((message) {
      if (!mounted) return;
      try {
        final decoded = jsonDecode(message);
        setState(() {
          _mensajes.add(decoded);
        });
      } catch (e) {
        debugPrint('Error parseando WS: $e');
      }
    });
  }

  @override
  void dispose() {
    _channel?.sink.close();
    _msgController.dispose();
    super.dispose();
  }

  Future<void> _loadHistorial() async {
    setState(() { _error = null; });
    try {
      final res = await ApiService.get('${AppConstants.adminChatManoEndpoint}${widget.alumnoId}');
      if (res is List) {
        setState(() {
          _mensajes = res;
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

  Future<void> _enviarMensaje() async {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;
    FocusScope.of(context).unfocus();
    
    _msgController.clear();
    
    if (_channel != null) {
      _channel!.sink.add(jsonEncode({'texto': text}));
    } else {
      try {
        await ApiService.postAuth('${AppConstants.adminChatManoEndpoint}${widget.alumnoId}', {
          'texto': text
        });
        await _loadHistorial();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryDark,
        title: Text('Chat con ${widget.alumnoNombre}', style: const TextStyle(color: Colors.white, fontSize: 18)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text('Error: $_error'))
                    : _mensajes.isEmpty
                        ? const Center(child: Text('No hay mensajes aún', style: TextStyle(color: AppTheme.textGray)))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            itemCount: _mensajes.length,
                            itemBuilder: (context, index) {
                              final msg = _mensajes[index];
                              final bool isAdmin = msg['emisor_rol'] == 'admin' || msg['emisor_rol'] == 'super_admin';
                              return Align(
                                alignment: isAdmin ? Alignment.centerRight : Alignment.centerLeft,
                                child: Container(
                                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isAdmin ? AppTheme.accentPurple : Colors.white,
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(16),
                                      topRight: const Radius.circular(16),
                                      bottomLeft: Radius.circular(isAdmin ? 16 : 0),
                                      bottomRight: Radius.circular(isAdmin ? 0 : 16)
                                    ),
                                    boxShadow: [
                                      BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5, offset: const Offset(0, 2))
                                    ]
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        msg['texto'] ?? '',
                                        style: TextStyle(
                                          color: isAdmin ? Colors.white : AppTheme.textDark,
                                          fontSize: 15
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
          ),
          
          // Escribir Mensaje
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -2))
              ]
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    decoration: InputDecoration(
                      hintText: 'Escribe tu respuesta...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                      filled: true,
                      fillColor: AppTheme.backgroundLight,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: AppTheme.accentPurple,
                  radius: 22,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: _enviarMensaje,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
