import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:dotenv/dotenv.dart' as dotenv;

String _secret() {
  final env = dotenv.env;
  return env['JWT_SECRET'] ?? 'replace_with_strong_secret';
}

String generateJwt(Map<String, dynamic> payload, {Duration exp = const Duration(hours: 2)}) {
  final jwt = JWT(payload, issuer: 'mymodus');
  return jwt.sign(SecretKey(_secret()), expiresIn: exp);
}

JWT? verifyJwt(String token) {
  try {
    final jwt = JWT.verify(token, SecretKey(_secret()));
    return jwt;
  } catch (e) {
    return null;
  }
}
