import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import '../models/product.dart';

class CacheService {
  static const _cacheFile = 'products_cache.json';

  static Future<String> _localPath() async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  static Future<void> saveProducts(List<Product> products) async {
    try {
      final path = await _localPath();
      final file = File('$path/$_cacheFile');
      final jsonStr = json.encode(products.map((p) => p.toJson()).toList());
      await file.writeAsString(jsonStr, flush: true);
    } catch (e) {
    }
  }

  static Future<List<Product>> loadProducts() async {
    try {
      final path = await _localPath();
      final file = File('$path/$_cacheFile');
      if (!await file.exists()) return [];
      final s = await file.readAsString();
      final arr = json.decode(s) as List<dynamic>;
      return arr.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }
}
