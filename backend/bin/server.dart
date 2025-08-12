import 'dart:io';
import 'dart:convert';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:dotenv/dotenv.dart' as dotenv;
import '../lib/db.dart';
import '../lib/connectors/scraper.dart';
import '../lib/ai/ai_service.dart';
import '../lib/web3/web3_service.dart';
import '../lib/kms.dart';

void main(List<String> args) async {
  dotenv.load();
  final db = await DB.connect();

  final app = Router();

  app.get('/healthz', (Request req) => Response.ok('ok'));

  app.get('/products', (Request req) async {
    try {
      final results = await db.conn.query('SELECT external_id, title, price, image, source_url FROM products ORDER BY created_at DESC LIMIT 100');
      final list = results.map((r) => {
        'external_id': r[0],
        'title': r[1],
        'price': r[2],
        'image': r[3],
        'source_url': r[4]
      }).toList();
      return Response.ok(jsonEncode(list), headers: {'content-type': 'application/json'});
    } catch (e) {
      return Response(500, body: jsonEncode({'error': e.toString()}), headers: {'content-type': 'application/json'});
    }
  });

  app.post('/scrape', (Request req) async {
    try {
      final body = await req.readAsString();
      final data = jsonDecode(body);
      final url = data['url'] as String?;
      if (url == null) return Response(400, body: jsonEncode({'error': 'url required'}), headers: {'content-type': 'application/json'});
      final scraped = await scrapeProductFromUrl(url);
      if (scraped == null) return Response(500, body: jsonEncode({'error': 'scrape failed'}), headers: {'content-type': 'application/json'});
      // upsert product
      await db.conn.transaction((ctx) async {
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
      });
      return Response.ok(jsonEncode(scraped), headers: {'content-type': 'application/json'});
    } catch (e) {
      return Response(500, body: jsonEncode({'error': e.toString()}), headers: {'content-type': 'application/json'});
    }
  });

  // AI endpoints
  app.post('/ai/generate-description', (Request req) async {
    try {
      final body = await req.readAsString();
      final data = jsonDecode(body);
      final prompt = data['prompt'] as String? ?? '';
      final svc = AIService();
      final out = await svc.generateDescription(prompt);
      return Response.ok(jsonEncode({'description': out}), headers: {'content-type': 'application/json'});
    } catch (e) {
      return Response(500, body: jsonEncode({'error': e.toString()}), headers: {'content-type': 'application/json'});
    }
  });

  app.post('/ai/embedding', (Request req) async {
    try {
      final body = await req.readAsString();
      final data = jsonDecode(body);
      final text = data['text'] as String? ?? '';
      final svc = AIService();
      final out = await svc.createEmbedding(text);
      return Response.ok(jsonEncode(out), headers: {'content-type': 'application/json'});
    } catch (e) {
      return Response(500, body: jsonEncode({'error': e.toString()}), headers: {'content-type': 'application/json'});
    }
  });

  // Web3 endpoints
  app.post('/wallets/create', (Request req) async {
    try {
      final body = await req.readAsString();
      final data = jsonDecode(body);
      final userId = data['user_id'];
      final passphrase = data['passphrase'] ?? 'devpass';
      // generate simple private key for dev (DO NOT use in prod)
      final pk = '0x' + List.generate(32, (i) => (DateTime.now().microsecondsSinceEpoch + i).toRadixString(16)).join().padRight(64, '0').substring(0,64);
      final web3 = Web3Service();
      final address = (await web3.addressFromPrivateKey(pk)).hex;
      // store key via KMS placeholder
      final kms = KMS('./backend/kms_storage');
      final id = address;
      await kms.storeKey(id, pk, passphrase);
      // save to DB
      await db.conn.query('INSERT INTO wallets (user_id, address, kms_ref, metadata) VALUES (@user, @address, @ref, @meta)', substitutionValues: {
        'user': userId,
        'address': address,
        'ref': id,
        'meta': jsonEncode({'dev': true})
      });
      return Response.ok(jsonEncode({'address': address, 'kms_ref': id}), headers: {'content-type': 'application/json'});
    } catch (e) {
      return Response(500, body: jsonEncode({'error': e.toString()}), headers: {'content-type': 'application/json'});
    }
  });

  app.get('/wallets/<address>/balance', (Request req, String address) async {
    try {
      final web3 = Web3Service();
      final bal = await web3.getBalance(address);
      return Response.ok(jsonEncode({'balance': bal.getInEther.toString()}), headers: {'content-type': 'application/json'});
    } catch (e) {
      return Response(500, body: jsonEncode({'error': e.toString()}), headers: {'content-type': 'application/json'});
    }
  });

  app.post('/web3/order-log', (Request req) async {
    try {
      final body = await req.readAsString();
      final data = jsonDecode(body);
      await db.conn.query('INSERT INTO orders_chain_log (order_id, user_id, order_hash, tx_hash, chain, status) VALUES (@order, @user, @oh, @tx, @chain, @st)', substitutionValues: {
        'order': data['order_id'],
        'user': data['user_id'],
        'oh': data['order_hash'],
        'tx': data['tx_hash'],
        'chain': data['chain'] ?? 'ethereum',
        'st': data['status'] ?? 'created'
      });
      return Response.ok(jsonEncode({'status': 'ok'}), headers: {'content-type': 'application/json'});
    } catch (e) {
      return Response(500, body: jsonEncode({'error': e.toString()}), headers: {'content-type': 'application/json'});
    }
  });

  final handler = Pipeline().addMiddleware(logRequests()).addHandler(app);
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await io.serve(handler, '0.0.0.0', port);
  print('Server running on port \${server.port}');
}
