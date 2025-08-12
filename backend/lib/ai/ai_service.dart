import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dotenv/dotenv.dart' as dotenv;

class AIService {
  final String apiKey;
  final String baseUrl;

  AIService():
    apiKey = dotenv.env['OPENAI_API_KEY'] ?? '',
    baseUrl = dotenv.env['OPENAI_API_BASE'] ?? 'https://api.openai.com/v1';

  Future<String> generateDescription(String prompt) async {
    if (apiKey.isEmpty) throw Exception('OPENAI_API_KEY not set');
    final res = await http.post(Uri.parse('\$baseUrl/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer \$apiKey'
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
    if (apiKey.isEmpty) throw Exception('OPENAI_API_KEY not set');
    final res = await http.post(Uri.parse('\$baseUrl/embeddings'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer \$apiKey'
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
