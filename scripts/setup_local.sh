#!/usr/bin/env bash
set -e
echo "Запуск локальной среды для MyModus (frontend + backend)"
echo "1) Backend"
cd backend
if [ -f .env ]; then
  echo "Using backend .env"
else
  cp .env.template .env
  echo "Created backend/.env from template — please edit DATABASE_URL and JWT_SECRET"
fi
# запускаем backend (требуется dart SDK)
echo "Запуск backend: dart run bin/server.dart &"
dart pub get
dart run bin/server.dart &

echo "2) Frontend"
cd ../frontend
echo "Если у вас установлен Flutter, выполните:"
echo "  flutter pub get"
echo "  flutter run -d chrome"
echo "Или соберите web: flutter build web"
