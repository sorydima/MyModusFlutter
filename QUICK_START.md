# 🚀 MyModus - Быстрый старт

## ⚡ За 5 минут

### 1. Клонирование
```bash
git clone https://github.com/your-username/MyModusFlutter.git
cd MyModusFlutter
```

### 2. Автозапуск
```bash
chmod +x scripts/setup_full.sh
./scripts/setup_full.sh
```

### 3. Готово! 🎉
- **Frontend**: http://localhost:3000
- **API**: http://localhost:8080
- **Grafana**: http://localhost:3001 (admin/admin)

## 🔧 Ручной запуск

### Требования
- Docker + Docker Compose
- Node.js 18+
- Flutter 3.0+

### Шаги
```bash
# 1. Создать .env
cp .env.example .env
# Отредактировать .env

# 2. Запустить сервисы
docker-compose -f docker-compose.full.yml up -d

# 3. Проверить статус
docker-compose -f docker-compose.full.yml ps
```

## 📱 Что получите

✅ **Парсинг** Ozon, Wildberries, Lamoda  
✅ **Соцсеть** в стиле Instagram  
✅ **Web3** интеграция + NFT  
✅ **AI** рекомендации  
✅ **Мониторинг** Prometheus + Grafana  
✅ **Логи** Elasticsearch + Kibana  

## 🆘 Проблемы?

```bash
# Логи
docker-compose -f docker-compose.full.yml logs -f

# Перезапуск
docker-compose -f docker-compose.full.yml restart

# Полный сброс
docker-compose -f docker-compose.full.yml down -v
docker-compose -f docker-compose.full.yml up -d
```

## 📚 Подробности

См. [README.md](README.md) для полной документации.

---

**MyModus** - запускаем за 5 минут! ⚡
