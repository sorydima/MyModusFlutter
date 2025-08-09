import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;
  ApiService(this.baseUrl);

  Future<Map<String, dynamic>> register(String email, String password) async {
    final res = await http.post(Uri.parse('\$baseUrl/api/v1/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}));
    return {'statusCode': res.statusCode, 'body': res.body};
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await http.post(Uri.parse('\$baseUrl/api/v1/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return {'token': data['token']};
    }
    return {'error': res.body};
  }
}
