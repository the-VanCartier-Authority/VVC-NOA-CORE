import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://vvc-noa-core.onrender.com';
  // Usa la misma clave configurada en APP_API_KEY de Render
  static const String appApiKey = 'vvc-secret-key-2026';

  Future<String> sendPrompt(String prompt) async {
    final url = Uri.parse('$baseUrl/api/v1/generate');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'X-API-Key': appApiKey,
        },
        body: jsonEncode({'prompt': prompt}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['output'] ?? 'Sin respuesta.';
      } else {
        return 'Error (${response.statusCode}): ${response.body}';
      }
    } catch (e) {
      return 'Error de red: $e';
    }
  }
}
