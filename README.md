# MyModusFlutter — Sprint 1 scaffold

Этот архив содержит полный набор файлов для выполнения **Sprint 1 (14 дней)**:
- scaffold фронтенда (Flutter) с i18n, GoRouter и темой;
- scaffold бэкенда (Dart Shelf) с JWT, PostgreSQL и health-check;
- GitHub Actions для CI (lint/test/build) и шаблон деплоя;
- простая страница-лендинг для GitHub Pages;
- шаблоны маркетинговых постов (Twitter, Telegram, Dev.to);
- шаблон доски задач (Trello/Notion) в Markdown;
- инструкции по применению и деплою.

> Как применить:
1. Распакуйте архив в корень вашего репозитория `MyModusFlutter` или в новую ветку:
   ```bash
   unzip mymodus_sprint1.zip -d mymodus_sprint1_tmp
   cp -r mymodus_sprint1_tmp/* /path/to/MyModusFlutter/
   ```
2. Просмотрите файлы, замените секреты и значения в `.github/workflows/*.yml`, `backend/.env.template`.
3. Создайте новую ветку, закоммитьте изменения и запушьте:
   ```bash
   git checkout -b feature/sprint1
   git add .
   git commit -m "feat(sprint1): scaffold frontend, backend, CI, landing, docs"
   git push origin feature/sprint1
   ```
4. Настройте секреты в GitHub: `DATABASE_URL`, `JWT_SECRET`, `GHCR_TOKEN` (если пушите образ), `RENDER_API_KEY` (если используете Render).
5. Запустите локально: `scripts/setup_local.sh`

---

