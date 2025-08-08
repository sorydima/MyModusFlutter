import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';

class FavoritesService {
  static const _key = 'my_modus_favorites';

  static Future<void> saveFavorites(List<Product> items) async {
    final prefs = await SharedPreferences.getInstance();
    final list = items.map((e) => json.encode(e.toJson())).toList();
    await prefs.setStringList(_key, list);
  }

  static Future<List<Product>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    return list.map((s) => Product.fromJson(json.decode(s))).toList();
  }
}
