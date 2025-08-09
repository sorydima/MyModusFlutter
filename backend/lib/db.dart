import 'package:postgres/postgres.dart';
import 'package:dotenv/dotenv.dart' as dotenv;

PostgreSQLConnection createConnection() {
  final env = dotenv.env;
  final uri = env['DATABASE_URL'] ?? 'postgres://user:password@localhost:5432/mymodus';
  // For simplicity we parse simple uri. In production use connection string parsing.
  final uriObj = Uri.parse(uri);
  final conn = PostgreSQLConnection(uriObj.host, uriObj.port, uriObj.path.replaceFirst('/', ''), 
    username: uriObj.userInfo.split(':').first, password: uriObj.userInfo.split(':').last);
  return conn;
}
