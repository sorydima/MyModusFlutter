#!/usr/bin/env dart

import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Тестирование интеграции с Avito
/// Этот скрипт проверяет работу всех компонентов интеграции с Avito
void main(List<String> args) async {
  print('🧪 Тестирование интеграции с Avito...\n');

  // 1. Проверяем доступность backend API
  await testBackendAPI();

  // 2. Проверяем парсинг Avito URL
  await testAvitoParser();

  // 3. Проверяем работу скрапера
  await testAvitoScraper();

  print('\n✅ Тестирование завершено!');
}

Future<void> testBackendAPI() async {
  print('📡 Проверка доступности backend API...');
  
  try {
    final response = await http.get(Uri.parse('http://localhost:8080/health'));
    
    if (response.statusCode == 200) {
      print('✅ Backend API доступен');
      final data = json.decode(response.body);
      print('   Статус: ${data['status']}');
    } else {
      print('❌ Backend API недоступен (код: ${response.statusCode})');
    }
  } catch (e) {
    print('❌ Ошибка подключения к backend: $e');
    print('   Убедитесь, что backend запущен на порту 8080');
  }
}

Future<void> testAvitoParser() async {
  print('\n🔍 Проверка парсера Avito...');
  
  const testUrl = 'https://www.avito.ru/moskva/odezhda_obuv_aksessuary/test_item_123';
  
  try {
    final response = await http.post(
      Uri.parse('http://localhost:8080/api/avito/parse'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'url': testUrl}),
    );
    
    if (response.statusCode == 200) {
      print('✅ Парсер Avito работает');
      final data = json.decode(response.body);
      print('   Результат: ${data['title'] ?? 'Нет названия'}');
    } else {
      print('❌ Ошибка парсера (код: ${response.statusCode})');
      print('   Ответ: ${response.body}');
    }
  } catch (e) {
    print('❌ Ошибка тестирования парсера: $e');
  }
}

Future<void> testAvitoScraper() async {
  print('\n🕷️ Проверка скрапера Avito...');
  
  try {
    final response = await http.post(
      Uri.parse('http://localhost:8080/api/scrape/avito'),
      headers: {'Content-Type': 'application/json'},
    );
    
    if (response.statusCode == 200) {
      print('✅ Скрапер Avito инициализирован');
      final data = json.decode(response.body);
      print('   Статус: ${data['status']}');
    } else {
      print('❌ Ошибка скрапера (код: ${response.statusCode})');
    }
  } catch (e) {
    print('❌ Ошибка тестирования скрапера: $e');
  }
}

/// Проверка валидности URL Avito
bool isValidAvitoUrl(String url) {
  try {
    final uri = Uri.parse(url);
    return uri.host.contains('avito.ru') && uri.path.contains('/');
  } catch (e) {
    return false;
  }
}

/// Демонстрация использования функций
void demonstrateUsage() {
  print('\n📚 Примеры использования:');
  
  const urls = [
    'https://www.avito.ru/moskva/odezhda_obuv_aksessuary/item_123',
    'https://www.avito.ru/user/2f8b6893c14fcb7aa600e1df2010ddd2/profile',
    'https://example.com/invalid',
  ];
  
  for (final url in urls) {
    final isValid = isValidAvitoUrl(url);
    print('   ${isValid ? '✅' : '❌'} $url');
  }
}

/// Инструкции по тестированию
void printInstructions() {
  print('\n📖 Инструкции по тестированию:');
  print('1. Запустите backend сервер: dart run backend/bin/server.dart');
  print('2. Запустите этот тест: dart run test_avito_integration.dart');
  print('3. Для тестирования UI запустите Flutter приложение');
  print('4. Откройте экран "Интеграция с Avito"');
  print('5. Протестируйте парсинг URL, поиск и категории');
}

/// Информация о новых возможностях
void printFeatures() {
  print('\n🚀 Новые возможности Avito интеграции:');
  print('• Парсинг товаров по URL');
  print('• Поиск товаров по ключевым словам');
  print('• Просмотр товаров по категориям');
  print('• Система избранного');
  print('• Отслеживание изменения цен');
  print('• Информация о продавцах');
  print('• Поддержка различных регионов');
  print('• AI-анализ описаний товаров');
  print('• Интеграция с Web3 кошельками');
}

/// Советы по оптимизации
void printOptimizationTips() {
  print('\n⚡ Советы по оптимизации:');
  print('• Используйте задержки между запросами для избежания блокировки');
  print('• Кэшируйте результаты парсинга для повторных запросов');
  print('• Используйте прокси для масштабирования');
  print('• Мониторьте изменения в структуре Avito');
  print('• Реализуйте обработку ошибок и retry логику');
}
