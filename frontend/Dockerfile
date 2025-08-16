FROM ubuntu:22.04 AS base

# Установка необходимых пакетов
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    && rm -rf /var/lib/apt/lists/*

# Установка Flutter
ENV FLUTTER_HOME="/opt/flutter"
ENV FLUTTER_VERSION="3.19.0"
ENV PATH="$FLUTTER_HOME/bin:$PATH"

RUN git clone https://github.com/flutter/flutter.git $FLUTTER_HOME
WORKDIR $FLUTTER_HOME
RUN git fetch && git checkout $FLUTTER_VERSION

# Pre-download Flutter artifacts
RUN flutter precache

# Установка Android SDK
ENV ANDROID_HOME="/opt/android-sdk"
ENV PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"

RUN mkdir -p $ANDROID_HOME/cmdline-tools
WORKDIR $ANDROID_HOME/cmdline-tools
RUN curl -o commandlinetools.zip https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip
RUN unzip commandlinetools.zip
RUN mv cmdline-tools latest

# Принятие лицензий
RUN yes | sdkmanager --licenses
RUN sdkmanager "platform-tools" "platforms;android-33" "build-tools;33.0.0"

# Настройка Flutter
RUN flutter doctor
RUN flutter config --no-analytics

WORKDIR /app

# Копирование pubspec файлов
COPY pubspec.* ./

# Установка зависимостей
RUN flutter pub get

# Копирование исходного кода
COPY . .

# Сборка для web
RUN flutter build web --release

# Production образ с nginx
FROM nginx:alpine AS runtime

# Копирование собранного приложения
COPY --from=base /app/build/web /usr/share/nginx/html

# Копирование nginx конфигурации
COPY nginx.conf /etc/nginx/nginx.conf

# Expose порт
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

# Запуск nginx
CMD ["nginx", "-g", "daemon off;"]
