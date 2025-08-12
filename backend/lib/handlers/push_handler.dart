
import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:http/http.dart' as http;

Future<Response> sendPushHandler(Request req) async {
  // Простой пример: принимает JSON { "token": "fcm_token", "title": "...", "body": "..." }
  final payload = jsonDecode(await req.readAsString());
  final token = payload['token'];
  final title = payload['title'] ?? 'MyModus';
  final body = payload['body'] ?? '';

  // Используем FCM HTTP v1 requires OAuth2 — здесь показан простой пример с legacy key (не рекомендуется в production)
  final serverKey = const String.fromEnvironment('FCM_SERVER_KEY', defaultValue: '');
  if (serverKey.isEmpty) {
    return Response.internalServerError(body: 'FCM_SERVER_KEY not configured');
  }

  final fcmUrl = Uri.parse('https://fcm.googleapis.com/fcm/send');
  final res = await http.post(fcmUrl, headers: {
    'Content-Type': 'application/json',
    'Authorization': 'key=\$serverKey',
  }, body: jsonEncode({
    'to': token,
    'notification': {'title': title, 'body': body},
    'data': payload['data'] ?? {},
  }));

  return Response(res.statusCode, body: res.body, headers: {'content-type': 'application/json'});
}
