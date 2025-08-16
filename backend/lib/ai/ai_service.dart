import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:dotenv/dotenv.dart';

class AIService {
  final Logger _logger = Logger();
  late final String _apiKey;
  late final String _baseUrl;

  AIService() {
    final env = DotEnv()..load();
    _apiKey = env['OPENAI_API_KEY'] ?? '';
    _baseUrl = env['OPENAI_BASE_URL'] ?? 'https://api.openai.com/v1';
  }

  Future<String> generateDescription(String prompt) async {
    if (_apiKey.isEmpty) throw Exception('OPENAI_API_KEY not set');
    final res = await http.post(Uri.parse('$_baseUrl/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey'
      },
      body: jsonEncode({
        'model': 'gpt-4o-mini', // placeholder: replace as needed
        'messages': [
          {'role': 'system', 'content': 'You are a helpful product description generator.'},
          {'role': 'user', 'content': prompt}
        ],
        'max_tokens': 200
      })
    );
    if (res.statusCode != 200) throw Exception('OpenAI error: ' + res.body);
    final data = jsonDecode(res.body);
    final text = data['choices']?[0]?['message']?['content'] ?? '';
    return text;
  }

  Future<Map<String, dynamic>> createEmbedding(String text) async {
    if (_apiKey.isEmpty) throw Exception('OPENAI_API_KEY not set');
    final res = await http.post(Uri.parse('$_baseUrl/embeddings'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey'
      },
      body: jsonEncode({
        'model': 'text-embedding-3-small',
        'input': text
      })
    );
    if (res.statusCode != 200) throw Exception('OpenAI error: ' + res.body);
    return jsonDecode(res.body);
  }
}
