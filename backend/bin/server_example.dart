
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import '../lib/handlers/auth_handler.dart' as auth;
import '../lib/handlers/push_handler.dart' as push;

void main(List<String> args) async {
  final router = Router();
  router.post('/api/auth/register', auth.registerHandler);
  router.post('/api/auth/login', auth.loginHandler);
  router.post('/api/auth/refresh', auth.refreshHandler);
  router.post('/api/push/send', push.sendPushHandler);

  final handler = Pipeline().addMiddleware(logRequests()).addHandler(router);

  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await io.serve(handler, InternetAddress.anyIPv4, port);
  print('Server running on localhost:\${server.port}');
}
