import 'dart:io';
import 'package:postgres/postgres.dart';

Future<PostgreSQLConnection> connectDb(String dbUrl) async {
  final uri = Uri.parse(dbUrl);
  final conn = PostgreSQLConnection(uri.host, uri.port, uri.path.replaceFirst('/', ''),
      username: uri.userInfo.split(':').first,
      password: uri.userInfo.split(':').length > 1 ? uri.userInfo.split(':')[1] : null);
  await conn.open();
  return conn;
}

void main(List<String> args) async {
  final dbUrl = Platform.environment['DATABASE_URL'] ?? 'postgres://mymodus:mymodus_pass@localhost:5432/mymodus_db';
  final migrationsDir = Directory('migrations');
  if (!migrationsDir.existsSync()) {
    print('migrations/ directory not found.');
    exit(1);
  }
  final files = migrationsDir.listSync().whereType<File>().toList()..sort((a,b)=>a.path.compareTo(b.path));
  final conn = await connectDb(dbUrl);
  try {
    for (final f in files) {
      final sql = await f.readAsString();
      print('Applying ' + f.path);
      await conn.transaction((ctx) async {
        await ctx.query(sql);
      });
    }
    print('Migrations applied.');
  } catch (e) {
    print('Migration error: \$e');
    exit(2);
  } finally {
    await conn.close();
  }
}
