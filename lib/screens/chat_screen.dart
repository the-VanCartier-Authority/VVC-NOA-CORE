import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../helpers/database_helper.dart';
import '../widgets/markdown_message_widget.dart';

class ChatScreen extends StatefulWidget {
  final String apiKey;
  final String wsUrl;

  const ChatScreen({
    Key? key,
    required this.apiKey,
    required this.wsUrl,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  WebSocketChannel? _channel;
  List<Map<String, dynamic>> _sessions = [];
  List<Map<String, dynamic>> _messages = [];

  String? _currentSessionId;
  String _currentSessionTitle = 'Nueva conversación';
  bool _isGenerating = false;
  String _currentStreamingText = '';

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _channel?.sink.close();
    super.dispose();
  }

  // --- CARGA DE SESIONES Y MENSAJES ---

  Future<void> _loadSessions() async {
    final sessions = await DatabaseHelper.instance.getSessions();
    setState(() {
      _sessions = sessions;
    });

    if (sessions.isNotEmpty && _currentSessionId == null) {
      _selectSession(sessions.first['id'], sessions.first['title']);
    } else if (sessions.isEmpty) {
      _createNewSession();
    }
  }

  Future<void> _selectSession(String sessionId, String title) async {
    final messages = await DatabaseHelper.instance.getMessages(sessionId);
    setState(() {
      _currentSessionId = sessionId;
      _currentSessionTitle = title;
      _messages = messages;
      _currentStreamingText = '';
    });
    _scrollToBottom();
  }

  Future<void> _createNewSession() async {
    final newId = DateTime.now().millisecondsSinceEpoch.toString();
    final title = 'Sesión ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}';

    await DatabaseHelper.instance.createSession(newId, title);
    await _loadSessions();
    await _selectSession(newId, title);
  }

  // --- LÓGICA DE MENSAJERÍA Y WEBSOCKET ---

  void _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _isGenerating || _currentSessionId == null) return;

    _textController.clear();

    // Guardar mensaje del usuario
    await DatabaseHelper.instance.insertMessage(_currentSessionId!, 'user', text);
    await _refreshMessages();

    setState(() {
      _isGenerating = true;
      _currentStreamingText = '';
    });

    try {
      final uri = Uri.parse('${widget.wsUrl}?api_key=${widget.apiKey}');
      _channel = WebSocketChannel.connect(uri);

      // Enviar payload al backend
      _channel!.sink.add(jsonEncode({
        'prompt': text,
        'stream': true,
      }));

      _channel!.stream.listen(
        (data) async {
          final response = jsonDecode(data);
          final type = response['type'];

          if (type == 'token') {
            setState(() {
              _currentStreamingText += response['content'] ?? '';
            });
            _scrollToBottom();
          } else if (type == 'end') {
            _finishStreaming();
          } else if (type == 'error') {
            _finishStreaming(errorText: '[ERROR: ${response['content']}]');
          }
        },
        onError: (error) {
          _finishStreaming(errorText: '[ERROR DE CONEXIÓN]');
        },
        onDone: () {
          if (_isGenerating) {
            _finishStreaming();
          }
        },
      );
    } catch (e) {
      _finishStreaming(errorText: '[FALLO AL CONECTAR CON EL SERVIDOR]');
    }
  }

  Future<void> _finishStreaming({String? errorText}) async {
    final finalText = errorText ?? _currentStreamingText;

    if (finalText.isNotEmpty && _currentSessionId != null) {
      await DatabaseHelper.instance.insertMessage(
        _currentSessionId!,
        'assistant',
        finalText,
      );
    }

    _channel?.sink.close();
    _channel = null;

    setState(() {
      _isGenerating = false;
      _currentStreamingText = '';
    });

    await _refreshMessages();
  }

  Future<void> _refreshMessages() async {
    if (_currentSessionId != null) {
      final messages = await DatabaseHelper.instance.getMessages(_currentSessionId!);
      setState(() {
        _messages = messages;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // --- INTERFAZ DE USUARIO ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        title: Text(
          _currentSessionTitle,
          style: const TextStyle(color: Color(0xFFF8FAFC), fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment_outlined, color: Color(0xFF38BDF8)),
            onPressed: _createNewSession,
            tooltip: 'Nueva conversación',
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _messages.length + (_isGenerating ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < _messages.length) {
                  final msg = _messages[index];
                  return MarkdownMessageWidget(
                    text: msg['text'],
                    isUser: msg['sender'] == 'user',
                  );
                } else {
                  return MarkdownMessageWidget(
                    text: _currentStreamingText.isEmpty ? '...' : _currentStreamingText,
                    isUser: false,
                  );
                }
              },
            ),
          ),
          _buildInputSection(),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFF0F172A),
      child: Column(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF1E293B)),
            child: Center(
              child: Text(
                'VVC-NOA HILOS',
                style: TextStyle(
                  color: Color(0xFF38BDF8),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.add, color: Color(0xFF38BDF8)),
            title: const Text(
              'Nueva Conversación',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.pop(context);
              _createNewSession();
            },
          ),
          const Divider(color: Color(0xFF334155)),
          Expanded(
            child: ListView.builder(
              itemCount: _sessions.length,
              itemBuilder: (context, index) {
                final session = _sessions[index];
                final isSelected = session['id'] == _currentSessionId;

                return ListTile(
                  selected: isSelected,
                  selectedTileColor: const Color(0xFF1E293B),
                  leading: Icon(
                    Icons.chat_bubble_outline,
                    color: isSelected ? const Color(0xFF38BDF8) : Colors.grey,
                  ),
                  title: Text(
                    session['title'],
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[400],
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _selectSession(session['id'], session['title']);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        border: Border(top: BorderSide(color: Color(0xFF334155))),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              enabled: !_isGenerating,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Escribe un mensaje...',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          IconButton(
            icon: Icon(
              _isGenerating ? Icons.hourglass_top : Icons.send,
              color: _isGenerating ? Colors.grey : const Color(0xFF38BDF8),
            ),
            onPressed: _isGenerating ? null : _sendMessage,
          ),
        ],
      ),
    );
  }
}
