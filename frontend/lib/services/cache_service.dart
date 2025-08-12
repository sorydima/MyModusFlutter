
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  Future<void> init() async {
    await Hive.initFlutter();
    // Регистрация адаптеров, если есть модели
    // Hive.registerAdapter(ProductAdapter());
    await Hive.openBox('cache_box');
  }

  Box get box => Hive.box('cache_box');

  dynamic get(String key) => box.get(key);
  Future<void> set(String key, dynamic value) async => await box.put(key, value);
  Future<void> remove(String key) async => await box.delete(key);
}
