import 'dart:io';
import 'dart:convert';
import 'package:postgres/postgres.dart';
import '../lib/scrapers/adapters/ozon_adapter.dart' as ozon;
import '../lib/scrapers/adapters/wb_adapter.dart' as wb;
import '../lib/scrapers/adapters/lamoda_adapter.dart' as lamoda;

Future<PostgreSQLConnection> connectDb() async {
  final dbUrl = Platform.environment['DATABASE_URL'] ?? 'postgres://mymodus:mymodus_pass@localhost:5432/mymodus_db';
  final uri = Uri.parse(dbUrl);
  final conn = PostgreSQLConnection(uri.host, uri.port, uri.path.replaceFirst('/', ''),
      username: uri.userInfo.split(':').first,
      password: uri.userInfo.split(':').length > 1 ? uri.userInfo.split(':')[1] : null);
  await conn.open();
  return conn;
}

Future<int> ensureMarketplace(PostgreSQLConnection conn, String code, String name) async {
  final res = await conn.query('SELECT id FROM marketplaces WHERE code = @code', substitutionValues: {'code': code});
  if (res.isNotEmpty) return res.first[0] as int;
  final ins = await conn.query('INSERT INTO marketplaces (code, name) VALUES (@code, @name) RETURNING id', substitutionValues: {'code': code, 'name': name});
  return ins.first[0] as int;
}

Future<int> upsertItem(PostgreSQLConnection conn, Map<String,dynamic> item, int marketplaceId) async {
  // check by external_id
  final res = await conn.query('SELECT id FROM items WHERE external_id = @external_id AND marketplace_id = @m', substitutionValues: {'external_id': item['external_id'], 'm': marketplaceId});
  if (res.isNotEmpty) return res.first[0] as int;
  final ins = await conn.query('INSERT INTO items (external_id, marketplace_id, title, description, price, currency, url, image_url) VALUES (@external_id, @m, @title, @desc, @price, @currency, @url, @image) RETURNING id', substitutionValues: {'external_id': item['external_id'], 'm': marketplaceId, 'title': item['title'], 'desc': item['description'], 'price': item['price'], 'currency': item['currency'], 'url': item['url'], 'image': item['image_url']});
  return ins.first[0] as int;
}

void main(List<String> args) async {
  final seedsFile = args.isNotEmpty ? args[0] : 'seeds/seed_urls.txt';
  final conn = await connectDb();

  final marketplacesMap = {'ozon':'Ozon','wb':'Wildberries','lamoda':'Lamoda'};
  final mapIds = <String,int>{};
  for (final e in marketplacesMap.entries) {
    mapIds[e.key] = await ensureMarketplace(conn, e.key, e.value);
  }

  final file = File(seedsFile);
  if (!file.existsSync()) {
    print('Seeds file not found: \$seedsFile');
    await conn.close();
    exit(1);
  }
  final lines = file.readAsLinesSync().where((l)=>l.trim().isNotEmpty).toList();
  for (final url in lines) {
    print('Processing: \$url');
    Map<String,dynamic> parsed = {};
    if (url.contains('ozon')) {
      parsed = await ozon.parseOzon(url);
    } else if (url.contains('wildberries') || url.contains('wb')) {
      parsed = await wb.parseWB(url);
    } else if (url.contains('lamoda')) {
      parsed = await lamoda.parseLamoda(url);
    } else {
      print('Unknown marketplace for url: \$url');
      continue;
    }
    if (parsed.containsKey('error')) {
      print('Parse error: ' + parsed['error']);
      continue;
    }
    final mid = mapIds[parsed['marketplace']] ?? mapIds.values.first;
    final itemId = await upsertItem(conn, parsed, mid);
    // create feed post by system user (user_id 1)
    try {
      await conn.query('INSERT INTO feed_posts (item_id, user_id, caption) VALUES (@item, @user, @caption)', substitutionValues: {'item': itemId, 'user': 1, 'caption': parsed['title'] ?? ''});
      print('Inserted feed post for item: \$itemId');
    } catch (e) {
      print('Feed insert error: \$e');
    }
  }

  await conn.close();
  print('Ingest finished.');
}
