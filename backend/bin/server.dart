import 'dart:io';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:dotenv/dotenv.dart' as dotenv;
import '../lib/auth.dart' as auth;

void main(List<String> args) async {
  dotenv.load();
  final app = Router();

  app.get('/healthz', (Request req) => Response.ok('ok'));

  app.post('/auth/login', (Request req) async {
    final payload = {'userId': 'test_user'}; // TODO: validate input
    final token = auth.generateJwt(payload);
    return Response.ok({'token': token}, headers: {'content-type': 'application/json'});
  });

  final handler = Pipeline().addMiddleware(logRequests()).addHandler(app);
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await io.serve(handler, '0.0.0.0', port);
  print('Server running on port ${server.port}');
}
