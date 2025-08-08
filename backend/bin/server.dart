import 'dart:io';
import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:html/parser.dart' as html_parser;

final _brandUrl = 'https://www.wildberries.ru/brands/311036101-my-modus';

Middleware corsHeaders() {
  return (Handler handler) {
    return (Request request) async {
      if (request.method == 'OPTIONS') {
        return Response.ok('',
            headers: {
              'access-control-allow-origin': '*',
              'access-control-allow-methods': 'GET, POST, OPTIONS',
              'access-control-allow-headers': 'Origin, Content-Type, Accept',
              'access-control-max-age': '3600',
            });
      }
      final response = await handler(request);
      return response.change(headers: {
        ...response.headers,
        'access-control-allow-origin': '*',
        'access-control-allow-methods': 'GET, POST, OPTIONS',
        'access-control-allow-headers': 'Origin, Content-Type, Accept',
      });
    };
  };
}

http.Client createHttpClient() {
  final proxy = Platform.environment['HTTP_PROXY'] ?? Platform.environment['http_proxy'];
  print('Proxy env var: $proxy (type: ${proxy.runtimeType})');
  
  if (proxy != null && proxy.isNotEmpty) {
    final uri = Uri.parse(proxy);
    print('Parsed proxy URI: $uri (type: ${uri.runtimeType})');

    final httpClient = HttpClient()
      ..findProxy = (url) => "PROXY ${uri.host}:${uri.port};"
      ..badCertificateCallback = (cert, host, port) => true;
    
    print('HttpClient created: $httpClient (type: ${httpClient.runtimeType})');
    return IOClient(httpClient);
  } else {
    print('No proxy, return default http.Client');
    return http.Client();
  }
}

Router getRouter() {
  final router = Router();
  final client = createHttpClient();

  router.get('/api/products', (Request req) async {
    try {
      final response = await client.get(
        Uri.parse(_brandUrl),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
              '(KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36',
          'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8',
          'Accept-Language': 'ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7',
          'Connection': 'keep-alive',
          'Referer': 'https://www.wildberries.ru/',
          'Upgrade-Insecure-Requests': '1',
          'Sec-Fetch-Site': 'same-origin',
          'Sec-Fetch-Mode': 'navigate',
          'Sec-Fetch-User': '?1',
          'Sec-Fetch-Dest': 'document',
        },
      );

      if (response.statusCode != 200) {
        print('Failed to fetch brand page, status: ${response.statusCode}');
        return Response.internalServerError(
            body: jsonEncode({'error': 'failed_fetch'}),
            headers: {'content-type': 'application/json'});
      }

      final document = html_parser.parse(response.body);
      final productCards = document.querySelectorAll('article.product-card');

      if (productCards.isEmpty) {
        print('No product cards found');
        return Response.internalServerError(
            body: jsonEncode({'error': 'no_products'}),
            headers: {'content-type': 'application/json'});
      }

      final products = productCards.map((card) {
        final linkElement = card.querySelector('a');
        final titleElement = card.querySelector('[aria-label]');
        final priceElement = card.querySelector('.price-commission__price');
        final oldPriceElement = card.querySelector('.price-commission__old-price');

        final link = linkElement?.attributes['href'] ?? '';
        final title = titleElement?.attributes['aria-label'] ?? '';
        final priceText = priceElement?.text.replaceAll(RegExp(r'[^0-9]'), '') ?? '';
        final oldPriceText = oldPriceElement?.text.replaceAll(RegExp(r'[^0-9]'), '') ?? '';

        return {
          'title': title,
          'link': link.isNotEmpty ? 'https://www.wildberries.ru$link' : '',
          'price': priceText.isNotEmpty ? int.parse(priceText) : null,
          'oldPrice': oldPriceText.isNotEmpty ? int.parse(oldPriceText) : null,
        };
      }).toList();

      return Response.ok(jsonEncode({'products': products}),
          headers: {'content-type': 'application/json'});
    } catch (e, st) {
      print('Exception: $e\n$st');
      return Response.internalServerError(
          body: jsonEncode({'error': e.toString()}),
          headers: {'content-type': 'application/json'});
    }
  });

  router.get('/', (Request req) => Response.ok('My Modus Backend with Wildberries HTML Parser'));

  return router;
}

void main(List<String> args) async {
  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsHeaders())
      .addHandler(getRouter());

  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await io.serve(handler, InternetAddress.anyIPv4, port);
  print('Server listening on port ${server.port}');
}

