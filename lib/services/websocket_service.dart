import 'dart:convert';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  // Reemplaza con tu dominio HTTPS convertido a wss://
  static const String wsUrl = 'wss://vvc-noa-core.onrender.com/ws/generate';
  static const String appApiKey = 'vvc-secret-key-2026';

  void connect({
    required Function(String token) onTokenReceived,
    required Function() onFinished,
    required Function(String error) onError,
  }) {
    final uri = Uri.parse('$wsUrl?api_key=$appApiKey');
    _channel = IOWebSocketChannel.connect(uri);

    _channel!.stream.listen(
      (message) {
        final data = jsonDecode(message);
        final type = data['type'];

        if (type == 'token') {
          onTokenReceived(data['content']);
        } else if (type == 'end') {
          onFinished();
        } else if (type == 'error') {
          onError(data['content']);
        }
      },
      onError: (error) => onError(error.toString()),
      onDone: () => onFinished(),
    );
  }

  void sendPrompt(String prompt) {
    if (_channel != null) {
      _channel!.sink.add(jsonEncode({'prompt': prompt}));
    }
  }

  void close() {
    _channel?.sink.close();
  }
}
