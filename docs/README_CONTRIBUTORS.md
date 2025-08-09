# Для контрибьюторов — быстрая настройка

## Требования
- Flutter SDK (stable)
- Dart SDK
- Postgres (локально или Docker)

## Локальный запуск
1. Создайте базу данных: `createdb mymodus_db`
2. Скопируйте `backend/.env.template` → `backend/.env` и задайте `DATABASE_URL` и `JWT_SECRET`
3. Запустите `scripts/setup_local.sh`
