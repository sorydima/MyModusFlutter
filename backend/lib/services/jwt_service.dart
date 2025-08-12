
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class JwtService {
  final String secret;
  JwtService(this.secret);

  String issueAccessToken(Map<String, dynamic> payload, {Duration expiresIn = const Duration(hours: 1)}) {
    final jwt = JWT(payload, issuer: 'my-modus');
    return jwt.sign(SecretKey(secret), expiresIn: expiresIn);
  }

  Map<String, dynamic>? verify(String token) {
    try {
      final jwt = JWT.verify(token, SecretKey(secret));
      return jwt.payload as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }
}
