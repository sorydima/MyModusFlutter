import 'dart:io';
import 'dart:convert';
import 'package:postgres/postgres.dart';

Future<PostgreSQLConnection> connectDb() async {
  final dbUrl = Platform.environment['DATABASE_URL'] ?? 'postgres://mymodus:mymodus_pass@localhost:5432/mymodus_db';
  final uri = Uri.parse(dbUrl);
  final conn = PostgreSQLConnection(uri.host, uri.port, uri.path.replaceFirst('/', ''),
      username: uri.userInfo.split(':').first,
      password: uri.userInfo.split(':').length > 1 ? uri.userInfo.split(':')[1] : null);
  await conn.open();
  return conn;
}

void main(List<String> args) async {
  print('Worker started');
  final conn = await connectDb();

  // Simple example job: ensure marketplaces exist
  final marketplaces = [
    {'code': 'ozon', 'name': 'Ozon'},
    {'code': 'wb', 'name': 'Wildberries'},
    {'code': 'lamoda', 'name': 'Lamoda'}
  ];
  for (final m in marketplaces) {
    try {
      await conn.query('INSERT INTO marketplaces (code, name) VALUES (@code, @name) ON CONFLICT (code) DO NOTHING', substitutionValues: m);
    } catch (e) {
      print('Marketplace insert error: \$e');
    }
  }

  // Placeholder: here would be scheduler loop fetching from queue and running scrapers
  while (true) {
    print('Worker heartbeat: ' + DateTime.now().toIso8601String());
    await Future.delayed(Duration(seconds: 30));
  }
}
