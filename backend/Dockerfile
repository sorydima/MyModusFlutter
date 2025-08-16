FROM dart:3.2.0 AS build

WORKDIR /app

# Копирование pubspec файлов
COPY pubspec.* ./

# Установка зависимостей
RUN dart pub get

# Копирование исходного кода
COPY . .

# Сборка приложения
RUN dart compile exe bin/server.dart -o bin/server

# Production образ
FROM debian:bookworm-slim AS runtime

# Установка необходимых пакетов
RUN apt-get update && apt-get install -y \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Создание пользователя для безопасности
RUN groupadd -r mymodus && useradd -r -g mymodus mymodus

WORKDIR /app

# Копирование скомпилированного приложения
COPY --from=build /app/bin/server /app/bin/server

# Копирование миграций
COPY --from=build /app/migrations /app/migrations

# Смена владельца
RUN chown -R mymodus:mymodus /app

USER mymodus

# Expose порт
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

# Запуск приложения
CMD ["/app/bin/server"]
