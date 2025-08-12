import 'dart:convert';
import 'dart:io';
import 'package:dotenv/dotenv.dart' as dotenv;
import '../lib/db.dart';
import '../lib/connectors/scraper.dart';

Future<void> processJob(DB db, Map row) async {
  final id = row['id'] as int;
  final payload = jsonDecode(row['payload'] as String) as Map<String, dynamic>;
  final type = row['type'] as String;
  print('Processing job \$id type=\$type payload=\$payload');
  try {
    if (type == 'scrape_product') {
      final url = payload['url'] as String;
      final scraped = await scrapeProductFromUrl(url);
      if (scraped == null) throw Exception('scrape returned null');
      final conn = db.conn;
      await conn.transaction((ctx) async {
        await ctx.query('''
          INSERT INTO products (external_id, title, price, image, source_url, updated_at)
          VALUES (@external_id, @title, @price, @image, @source_url, now())
          ON CONFLICT (source_url) DO UPDATE SET
            title = EXCLUDED.title,
            price = EXCLUDED.price,
            image = EXCLUDED.image,
            updated_at = now();
        ''', substitutionValues: {
          'external_id': scraped['external_id'],
          'title': scraped['title'],
          'price': scraped['price'],
          'image': scraped['image'],
          'source_url': scraped['source_url']
        });
        await ctx.query('UPDATE jobs SET status = @status, updated_at = now() WHERE id = @id', substitutionValues: {
          'status': 'done',
          'id': id
        });
      });
    } else {
      throw Exception('unknown job type');
    }
  } catch (e) {
    print('Job \$id failed: \$e');
    final attempts = (row['attempts'] as int) + 1;
    final conn = db.conn;
    final nextRun = DateTime.now().add(Duration(seconds: attempts * 10));
    await conn.query('UPDATE jobs SET attempts = @attempts, last_error = @err, status = @status, run_at = @run_at, updated_at = now() WHERE id = @id', substitutionValues: {
      'attempts': attempts,
      'err': e.toString(),
      'status': 'pending',
      'run_at': nextRun.toUtc().toIso8601String(),
      'id': id
    });
  }
}

Future<void> pollLoop(DB db) async {
  while (true) {
    try {
      final rows = await db.conn.mappedResultsQuery('''
        SELECT id, type, payload, attempts FROM jobs
        WHERE status = 'pending' AND run_at <= now()
        ORDER BY created_at ASC
        LIMIT 1
      ''');
      if (rows.isEmpty) {
        await Future.delayed(Duration(seconds: 2));
        continue;
      }
      final row = rows.first.values.first;
      await db.conn.query('UPDATE jobs SET status = @status, updated_at = now() WHERE id = @id', substitutionValues: {
        'status': 'processing',
        'id': row['id']
      });
      await processJob(db, row);
    } catch (e) {
      print('Worker loop error: \$e');
      await Future.delayed(Duration(seconds: 5));
    }
  }
}

void main(List<String> args) async {
  dotenv.load();
  final db = await DB.connect();
  print('Worker connected to DB, starting poll loop...');
  await pollLoop(db);
}
