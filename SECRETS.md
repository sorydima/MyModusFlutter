# Секреты и переменные окружения

Добавьте в репозиторий (GitHub Secrets) следующие переменные:
- DATABASE_URL — строка подключения PostgreSQL (например, postgres://user:pass@host:5432/db)
- JWT_SECRET — сильная случайная строка для подписи JWT
- GHCR_TOKEN — (опционально) токен для пуша контейнера в GitHub Container Registry
- RENDER_API_KEY — (опционально) ключ для автоматического деплоя на Render
