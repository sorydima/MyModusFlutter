
import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../services/jwt_service.dart';

// NOTE: This is a minimal example for demo purposes only.
// In production use hashed passwords, proper user storage (DB), validations and HTTPS.

final JwtService jwtService = JwtService(const String.fromEnvironment('JWT_SECRET', defaultValue: 'changeme'));

Future<Response> registerHandler(Request req) async {
  final body = jsonDecode(await req.readAsString());
  final email = body['email'];
  final password = body['password'];
  if (email == null || password == null) {
    return Response(400, body: jsonEncode({'error': 'email and password required'}), headers: {'content-type': 'application/json'});
  }

  // TODO: save user to DB. Here we only simulate registration success.
  return Response.ok(jsonEncode({'status': 'ok'}), headers: {'content-type': 'application/json'});
}

Future<Response> loginHandler(Request req) async {
  final body = jsonDecode(await req.readAsString());
  final email = body['email'];
  final password = body['password'];
  if (email == null || password == null) {
    return Response(400, body: jsonEncode({'error': 'email and password required'}), headers: {'content-type': 'application/json'});
  }

  // TODO: verify user credentials from DB. For demo allow any credentials.
  final access = jwtService.issueAccessToken({'sub': email, 'role': 'user'});
  final refresh = jwtService.issueAccessToken({'sub': email, 'type': 'refresh'}, expiresIn: const Duration(days: 30));

  return Response.ok(jsonEncode({'access_token': access, 'refresh_token': refresh}), headers: {'content-type': 'application/json'});
}

Future<Response> refreshHandler(Request req) async {
  final body = jsonDecode(await req.readAsString());
  final refresh = body['refresh_token'];
  if (refresh == null) {
    return Response(400, body: jsonEncode({'error': 'refresh_token required'}), headers: {'content-type': 'application/json'});
  }
  final payload = jwtService.verify(refresh);
  if (payload == null) {
    return Response(401, body: jsonEncode({'error': 'invalid refresh token'}), headers: {'content-type': 'application/json'});
  }
  // Issue new access token
  final access = jwtService.issueAccessToken({'sub': payload['sub'], 'role': payload['role'] ?? 'user'});
  return Response.ok(jsonEncode({'access_token': access}), headers: {'content-type': 'application/json'});
}
