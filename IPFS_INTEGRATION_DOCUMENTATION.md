# MyModus IPFS Integration Documentation

## 📋 Обзор

IPFS (InterPlanetary File System) интеграция в MyModus обеспечивает децентрализованное хранение файлов, метаданных NFT и медиа контента. Это ключевой компонент Web4 архитектуры проекта.

## 🏗️ Архитектура

### Компоненты IPFS инфраструктуры:

1. **IPFS Node** - основной узел для хранения и распространения файлов
2. **IPFS Cluster** - управление несколькими IPFS узлами
3. **IPFS Gateway** - HTTP интерфейс для доступа к файлам
4. **IPFS Dashboard** - веб-интерфейс для мониторинга
5. **Prometheus** - система мониторинга и метрик
6. **Nginx** - обратный прокси с кэшированием

### Схема архитектуры:

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   MyModus App   │    │   IPFS Client   │    │   Web Browser   │
└─────────┬───────┘    └─────────┬───────┘    └─────────┬───────┘
          │                      │                      │
          └──────────────────────┼──────────────────────┘
                                 │
                    ┌─────────────┴─────────────┐
                    │      IPFS Gateway         │
                    │      (Nginx + Cache)      │
                    └─────────────┬─────────────┘
                                 │
                    ┌─────────────┴─────────────┐
                    │       IPFS Node           │
                    │    (Kubo + Storage)       │
                    └─────────────┬─────────────┘
                                 │
                    ┌─────────────┴─────────────┐
                    │      IPFS Cluster         │
                    │   (Multi-node support)    │
                    └───────────────────────────┘
```

## 🚀 Быстрый старт

### Предварительные требования:

- Docker Desktop
- Docker Compose
- 10GB свободного места на диске
- Порты 4001, 5001, 8080, 8081, 9090, 9094, 9095, 5000

### Запуск на Linux/Mac:

```bash
# Сделать скрипт исполняемым
chmod +x scripts/start_ipfs.sh

# Запустить IPFS инфраструктуру
./scripts/start_ipfs.sh start

# Проверить статус
./scripts/start_ipfs.sh status

# Просмотр логов
./scripts/start_ipfs.sh logs
```

### Запуск на Windows:

```powershell
# Запустить IPFS инфраструктуру
.\scripts\start_ipfs.ps1 start

# Проверить статус
.\scripts\start_ipfs.ps1 status

# Просмотр логов
.\scripts\start_ipfs.ps1 logs
```

### Проверка работоспособности:

```bash
# IPFS Node API
curl http://localhost:5001/api/v0/version

# IPFS Gateway
curl http://localhost:8080/ipfs/QmUNLLsPACCz1vLxQVkXqqLX5R1X345qqfHbsf67hvA3Nn

# IPFS Dashboard
open http://localhost:5000

# Prometheus
open http://localhost:9090
```

## 🔧 Конфигурация

### Переменные окружения:

```bash
# IPFS Node URL
IPFS_NODE_URL=http://localhost:5001

# IPFS Gateway URL
IPFS_GATEWAY_URL=http://localhost:8080/ipfs

# Cluster Secret (для production)
CLUSTER_SECRET=your-secure-secret-here

# IPFS Profile (server, client, badgerds, etc.)
IPFS_PROFILE=server
```

### Docker Compose конфигурация:

Основная конфигурация находится в `docker-compose.ipfs.yml`:

- **IPFS Node**: порт 5001 (API), 8080 (Gateway), 4001 (P2P)
- **IPFS Cluster**: порт 9094 (API), 9095 (Proxy)
- **IPFS Dashboard**: порт 5000
- **Prometheus**: порт 9090
- **Nginx Gateway**: порт 8081

### Nginx конфигурация:

Файл `nginx-ipfs.conf` содержит:

- Кэширование IPFS файлов
- Gzip сжатие
- CORS заголовки
- Обработка ошибок
- Мониторинг

## 📚 API Reference

### IPFS Service Methods:

#### Загрузка файлов:

```dart
// Загрузка файла
Future<String> uploadFile({
  required Uint8List fileData,
  required String fileName,
  String? contentType,
  Map<String, dynamic>? metadata,
});

// Загрузка метаданных
Future<String> uploadMetadata({
  required Map<String, dynamic> metadata,
  String? fileName,
});

// Загрузка NFT метаданных
Future<String> uploadNFTMetadata({
  required String name,
  required String description,
  required String imageUrl,
  required List<Map<String, dynamic>> attributes,
  String? externalUrl,
  Map<String, dynamic>? additionalData,
});
```

#### Получение файлов:

```dart
// Получение файла по хешу
Future<Uint8List> getFile(String hash);

// Получение метаданных
Future<Map<String, dynamic>> getMetadata(String hash);

// Получение NFT метаданных
Future<Map<String, dynamic>> getNFTMetadata(String hash);
```

#### Управление файлами:

```dart
// Проверка доступности
Future<bool> isFileAvailable(String hash);

// Получение информации о файле
Future<Map<String, dynamic>> getFileInfo(String hash);

// Закрепление файла
Future<bool> pinFile(String hash);

// Открепление файла
Future<bool> unpinFile(String hash);
```

#### Кэш и статистика:

```dart
// Статистика кэша
Map<String, dynamic> getCacheStats();

// Очистка кэша
void clearCache();

// Очистка устаревших записей
void cleanExpiredCache();
```

### HTTP API Endpoints:

#### Загрузка:

```http
POST /api/v1/ipfs/upload
Content-Type: multipart/form-data

POST /api/v1/ipfs/upload/metadata
Content-Type: application/json

POST /api/v1/ipfs/upload/nft
Content-Type: application/json
```

#### Получение:

```http
GET /api/v1/ipfs/file/{hash}
GET /api/v1/ipfs/metadata/{hash}
GET /api/v1/ipfs/nft/{hash}
GET /api/v1/ipfs/file/{hash}/info
```

#### Управление:

```http
POST /api/v1/ipfs/pin/{hash}
DELETE /api/v1/ipfs/pin/{hash}
GET /api/v1/ipfs/pins
HEAD /api/v1/ipfs/file/{hash}/status
```

#### Кэш:

```http
GET /api/v1/ipfs/cache/stats
DELETE /api/v1/ipfs/cache
POST /api/v1/ipfs/cache/clean
```

## 🧪 Тестирование

### Unit тесты:

```bash
# Запуск тестов IPFS сервиса
cd backend
dart test test/ipfs_service_test.dart

# Запуск всех тестов
dart test
```

### Интеграционные тесты:

```bash
# Запуск IPFS инфраструктуры
./scripts/start_ipfs.sh start

# Тестирование API
curl -X POST http://localhost:8080/api/v1/ipfs/upload \
  -F "file=@test_file.jpg" \
  -F "metadata={\"type\":\"test\"}"

# Проверка загрузки
curl http://localhost:8080/api/v1/ipfs/file/{hash}
```

### Тестовые данные:

```dart
// Создание тестового файла
final testFile = Uint8List.fromList([1, 2, 3, 4, 5]);

// Создание тестовых метаданных
final testMetadata = {
  'name': 'Test File',
  'description': 'Test description',
  'type': 'test'
};

// Создание тестовых NFT метаданных
final testNFTMetadata = {
  'name': 'Test NFT',
  'description': 'Test NFT description',
  'imageUrl': 'ipfs://QmImageHash',
  'attributes': [
    {'trait_type': 'Rarity', 'value': 'Common'},
    {'trait_type': 'Type', 'value': 'Badge'}
  ]
};
```

## 📊 Мониторинг

### Prometheus метрики:

- **IPFS Node**: размер репозитория, количество пиров, скорость загрузки
- **IPFS Cluster**: количество узлов, статус синхронизации
- **Gateway**: количество запросов, время ответа, размер кэша

### Grafana дашборды:

Предустановленные дашборды для:
- IPFS Node статистики
- Cluster мониторинга
- Gateway производительности
- Системных ресурсов

### Логирование:

```bash
# Просмотр логов IPFS узла
docker logs mymodus-ipfs-node

# Просмотр логов Gateway
docker logs mymodus-ipfs-gateway

# Просмотр логов Cluster
docker logs mymodus-ipfs-cluster
```

## 🔒 Безопасность

### CORS настройки:

```nginx
# Разрешенные источники
add_header Access-Control-Allow-Origin * always;

# Разрешенные методы
add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS" always;

# Разрешенные заголовки
add_header Access-Control-Allow-Headers "Authorization, Content-Type" always;
```

### Аутентификация:

```dart
// Проверка JWT токена в IPFS хендлере
final token = request.headers['authorization']?.replaceFirst('Bearer ', '');
if (token != null) {
  final isValid = await _jwtService.validateToken(token);
  if (!isValid) {
    return Response.unauthorized('Invalid token');
  }
}
```

### Rate Limiting:

```nginx
# Ограничение количества запросов
limit_req_zone $binary_remote_addr zone=ipfs:10m rate=10r/s;
limit_req zone=ipfs burst=20 nodelay;
```

## 🚀 Production Deployment

### Масштабирование:

1. **Горизонтальное масштабирование IPFS узлов**
2. **Load balancer для Gateway**
3. **Redis кластер для кэширования**
4. **CDN для статических файлов**

### Мониторинг:

1. **Prometheus + Grafana**
2. **ELK Stack для логов**
3. **Alerting на критические события**
4. **Health checks для всех сервисов**

### Backup и восстановление:

```bash
# Backup IPFS данных
docker exec mymodus-ipfs-node ipfs repo gc
docker cp mymodus-ipfs-node:/data/ipfs ./ipfs-backup

# Восстановление
docker cp ./ipfs-backup mymodus-ipfs-node:/data/ipfs
docker restart mymodus-ipfs-node
```

## 🔧 Troubleshooting

### Частые проблемы:

#### IPFS узел не запускается:

```bash
# Проверка логов
docker logs mymodus-ipfs-node

# Проверка портов
netstat -tulpn | grep :5001

# Перезапуск сервиса
docker restart mymodus-ipfs-node
```

#### Gateway недоступен:

```bash
# Проверка Nginx
docker logs mymodus-ipfs-gateway

# Проверка конфигурации
docker exec mymodus-ipfs-gateway nginx -t

# Перезапуск Gateway
docker restart mymodus-ipfs-gateway
```

#### Проблемы с кэшированием:

```bash
# Очистка кэша
curl -X DELETE http://localhost:8080/api/v1/ipfs/cache

# Проверка статистики кэша
curl http://localhost:8080/api/v1/ipfs/cache/stats
```

### Полезные команды:

```bash
# Статус всех сервисов
docker-compose -f docker-compose.ipfs.yml ps

# Логи всех сервисов
docker-compose -f docker-compose.ipfs.yml logs -f

# Перезапуск всех сервисов
docker-compose -f docker-compose.ipfs.yml restart

# Остановка всех сервисов
docker-compose -f docker-compose.ipfs.yml down
```

## 📈 Производительность

### Оптимизация:

1. **Кэширование**: Nginx + Redis
2. **Сжатие**: Gzip для текстовых файлов
3. **CDN**: для популярного контента
4. **Load Balancing**: распределение нагрузки

### Бенчмарки:

```bash
# Тест производительности загрузки
ab -n 100 -c 10 -p test_file.jpg http://localhost:8080/api/v1/ipfs/upload

# Тест производительности получения
ab -n 1000 -c 50 http://localhost:8080/ipfs/{hash}

# Тест кэширования
curl -H "Cache-Control: no-cache" http://localhost:8080/ipfs/{hash}
```

## 🔮 Будущие улучшения

### Планируемые функции:

1. **IPFS Pinning Service** - автоматическое закрепление важных файлов
2. **Filecoin интеграция** - оплата за долгосрочное хранение
3. **IPNS поддержка** - обновляемые ссылки на контент
4. **Multi-format поддержка** - различные форматы хеширования
5. **IPFS Cluster UI** - веб-интерфейс для управления кластером

### Roadmap:

- **Q1 2024**: Базовая IPFS интеграция ✅
- **Q2 2024**: Pinning Service + Filecoin
- **Q3 2024**: Advanced monitoring + Analytics
- **Q4 2024**: Enterprise features + SLA

## 📞 Поддержка

### Полезные ссылки:

- [IPFS Documentation](https://docs.ipfs.io/)
- [IPFS GitHub](https://github.com/ipfs/ipfs)
- [IPFS Community](https://discuss.ipfs.io/)
- [IPFS Blog](https://blog.ipfs.io/)

### Контакты:

- **Issues**: GitHub Issues в репозитории MyModus
- **Discussions**: GitHub Discussions
- **Documentation**: Этот файл и связанная документация

---

**MyModus IPFS Integration** - Децентрализованное будущее файлового хранения! 🚀
