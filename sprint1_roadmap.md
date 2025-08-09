# Sprint 1 (14 дней) — Roadmap (автоматически сгенерирован)

## День 1–3 — Подготовка и инфраструктура
- [ ] Создать Notion/Trello board (файл `tasks_board.md`).
- [ ] Настроить GitHub Actions:
  - [ ] Линтер + тесты (Flutter/Dart)
  - [ ] Сборка Flutter Web
  - [ ] Docker build для backend
- [ ] Создать dev/staging окружения (Render/VPS) — примеры `render.yaml`.

## День 4–7 — Кодовая база
### Фронт (Flutter)
- [ ] Подключить i18n (en/ru) — `frontend/lib/l10n/`
- [ ] Добавить начальный дизайн-гайд — `frontend/lib/theme.dart`
- [ ] Обновить навигацию (GoRouter) — `frontend/lib/router.dart`

### Бэк (Dart Shelf)
- [ ] Подключить PostgreSQL — `backend/lib/db.dart`
- [ ] Добавить базовую авторизацию (JWT) — `backend/lib/auth.dart`
- [ ] Создать health-check endpoint — `/healthz`

## День 8–10 — Минимум для релиза
- [ ] Собрать Flutter Web билд на gh-pages — workflow `deploy-gh-pages.yml`
- [ ] Прогнать тесты, исправить ошибки
- [ ] Настроить авто-деплой staging версии — `render.yaml` / `docker-compose.staging.yml`

## День 11–14 — Продвижение
- [ ] Лэндинг (GitHub Pages) — `landing/index.html`
- [ ] Создать посты (Twitter, Telegram, Dev.to) — `marketing/`
- [ ] Подготовить короткое демо-видео — `demo_video_script.md`

---

