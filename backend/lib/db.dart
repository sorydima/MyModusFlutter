import 'package:postgres/postgres.dart';
import 'package:dotenv/dotenv.dart' as dotenv;

class DB {
  late PostgreSQLConnection conn;
  DB._create(this.conn);

  static Future<DB> connect() async {
    dotenv.load();
    final uri = dotenv.env['DATABASE_URL'] ?? 'postgres://mymodus:example@localhost:5432/mymodus_db';
    final uriObj = Uri.parse(uri);
    final conn = PostgreSQLConnection(uriObj.host, uriObj.port, uriObj.path.replaceFirst('/', ''),
      username: uriObj.userInfo.split(':').first, password: uriObj.userInfo.split(':').last);
    await conn.open();
    return DB._create(conn);
  }
}
