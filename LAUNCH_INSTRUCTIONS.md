# 🚀 Инструкции по запуску MyModus IPFS Integration

## 📋 Предварительные требования

### Системные требования
- **OS**: Windows 10/11, macOS 10.15+, Ubuntu 18.04+
- **RAM**: минимум 4GB, рекомендуется 8GB+
- **Storage**: минимум 10GB свободного места
- **Network**: стабильное интернет-соединение

### Установленные компоненты
- **Docker**: версия 20.10+
- **Docker Compose**: версия 2.0+
- **Flutter**: версия 3.10+
- **Dart**: версия 3.0+
- **Git**: для клонирования репозитория

## 🔧 Пошаговый запуск

### Шаг 1: Подготовка окружения

```bash
# Клонирование репозитория (если еще не сделано)
git clone <repository-url>
cd MyModusFlutter

# Проверка Docker
docker --version
docker-compose --version

# Проверка Flutter
flutter --version
dart --version
```

### Шаг 2: Запуск IPFS инфраструктуры

#### Windows (PowerShell)
```powershell
# Запуск от имени администратора
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
.\scripts\start_ipfs.ps1
```

#### Linux/macOS
```bash
# Установка прав на выполнение
chmod +x scripts/start_ipfs.sh

# Запуск
./scripts/start_ipfs.sh
```

#### Проверка запуска
```bash
# Проверка контейнеров
docker ps

# Проверка IPFS узла
curl http://localhost:5001/api/v0/version

# Проверка IPFS Gateway
curl http://localhost:8080/ipfs/QmYwAPJzv5CZsnA625s3Xf2nemtYgPpHdWEz79ojWnPbdG
```

### Шаг 3: Настройка backend

```bash
cd backend

# Установка зависимостей
dart pub get

# Настройка переменных окружения
cp .env.example .env

# Редактирование .env файла
# IPFS_API_URL=http://localhost:5001
# IPFS_GATEWAY_URL=http://localhost:8080
# IPFS_CLUSTER_URL=http://localhost:9094

# Запуск backend
dart run
```

### Шаг 4: Настройка frontend

```bash
cd frontend

# Установка зависимостей
flutter pub get

# Настройка переменных окружения
cp .env.example .env

# Редактирование .env файла
# BACKEND_URL=http://localhost:8080
# IPFS_GATEWAY_URL=http://localhost:8080

# Запуск frontend
flutter run
```

## 🧪 Тестирование интеграции

### Backend тесты
```bash
cd backend
dart test
```

### Frontend тесты
```bash
cd frontend
flutter test
```

### Интеграционные тесты
```bash
# Запуск всех тестов
./scripts/run_tests.sh
```

## 📱 Использование приложения

### 1. Открытие IPFS вкладки
- Запустите приложение
- Перейдите на вкладку IPFS в нижней навигации

### 2. Загрузка файлов
- Нажмите FAB (круглая кнопка с +)
- Выберите тип файла или перетащите файлы
- Заполните метаданные при необходимости

### 3. Создание NFT
- Нажмите кнопку "Создать NFT"
- Загрузите изображение
- Добавьте атрибуты и описание
- Создайте NFT

### 4. Управление файлами
- Просматривайте загруженные файлы
- Закрепляйте важные файлы
- Удаляйте ненужные файлы
- Изучайте статистику

## 🔍 Мониторинг и управление

### IPFS Dashboard
- **URL**: http://localhost:5001/webui
- **Функции**: управление узлом, мониторинг, настройки

### Prometheus Metrics
- **URL**: http://localhost:9090
- **Функции**: метрики производительности, алерты

### Nginx Gateway
- **URL**: http://localhost:8080
- **Функции**: кэширование, оптимизация, балансировка

## 🚨 Устранение неполадок

### Проблемы с Docker
```bash
# Перезапуск Docker
docker-compose -f docker-compose.ipfs.yml down
docker-compose -f docker-compose.ipfs.yml up -d

# Очистка контейнеров
docker system prune -a
```

### Проблемы с IPFS
```bash
# Проверка логов
docker logs ipfs-node
docker logs ipfs-cluster

# Перезапуск IPFS
docker restart ipfs-node
docker restart ipfs-cluster
```

### Проблемы с Flutter
```bash
# Очистка кэша
flutter clean
flutter pub get

# Проверка зависимостей
flutter doctor
```

### Проблемы с backend
```bash
# Проверка логов
dart run --verbose

# Проверка портов
netstat -an | grep 8080
```

## 📊 Проверка работоспособности

### Тест загрузки файла
1. Откройте IPFS вкладку
2. Загрузите тестовое изображение
3. Проверьте появление в списке файлов
4. Проверьте доступность через gateway

### Тест создания NFT
1. Создайте NFT с тестовым изображением
2. Проверьте сохранение метаданных
3. Проверьте доступность через IPFS

### Тест API endpoints
```bash
# Проверка health check
curl http://localhost:8080/health

# Проверка IPFS endpoints
curl http://localhost:8080/api/ipfs/files
```

## 🔒 Безопасность

### Рекомендации
- Используйте HTTPS в продакшене
- Настройте firewall правила
- Ограничьте доступ к IPFS API
- Регулярно обновляйте зависимости

### Переменные окружения
```bash
# Обязательные
IPFS_API_URL=
IPFS_GATEWAY_URL=
BACKEND_URL=

# Опциональные
IPFS_CLUSTER_URL=
PROMETHEUS_URL=
NGINX_PORT=
```

## 📈 Масштабирование

### Горизонтальное масштабирование
```bash
# Увеличение количества IPFS узлов
docker-compose -f docker-compose.ipfs.yml up -d --scale ipfs-node=3

# Настройка кластера
docker-compose -f docker-compose.ipfs.yml up -d ipfs-cluster
```

### Вертикальное масштабирование
```bash
# Увеличение ресурсов в docker-compose
services:
  ipfs-node:
    deploy:
      resources:
        limits:
          memory: 2G
          cpus: '1.0'
```

## 🎯 Следующие шаги

### Production deployment
1. Настройка SSL сертификатов
2. Настройка доменных имен
3. Настройка мониторинга и алертов
4. Настройка backup стратегии

### Feature expansion
1. Добавление шифрования файлов
2. Интеграция с Web3 кошельками
3. Добавление P2P функций
4. Расширение NFT возможностей

---

## 📞 Поддержка

При возникновении проблем:
1. Проверьте логи Docker контейнеров
2. Проверьте документацию в папке docs/
3. Создайте issue в репозитории
4. Обратитесь к команде разработки

---

**Статус**: ✅ ГОТОВО К ЗАПУСКУ  
**Последнее обновление**: ${new Date().toLocaleDateString()}  
**Версия**: 1.0.0
