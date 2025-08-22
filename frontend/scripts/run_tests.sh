#!/bin/bash

# MyModus Test Runner Script
# Запуск всех тестов для Flutter приложения

set -e

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Функции для логирования
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Проверка зависимостей
check_dependencies() {
    log_info "Проверка зависимостей..."
    
    if ! command -v flutter &> /dev/null; then
        log_error "Flutter не установлен. Установите Flutter SDK."
        exit 1
    fi
    
    if ! command -v dart &> /dev/null; then
        log_error "Dart не установлен. Установите Dart SDK."
        exit 1
    fi
    
    log_success "Все зависимости установлены"
}

# Очистка проекта
clean_project() {
    log_info "Очистка проекта..."
    
    flutter clean
    flutter pub get
    
    log_success "Проект очищен"
}

# Генерация моков
generate_mocks() {
    log_info "Генерация моков для тестов..."
    
    if [ -f "test/widget_tests.mocks.dart" ]; then
        rm test/widget_tests.mocks.dart
    fi
    
    if [ -f "test/integration_tests.mocks.dart" ]; then
        rm test/integration_tests.mocks.dart
    fi
    
    flutter packages pub run build_runner build --delete-conflicting-outputs
    
    log_success "Моки сгенерированы"
}

# Запуск unit тестов
run_unit_tests() {
    log_info "Запуск unit тестов..."
    
    if [ -d "test/unit" ]; then
        flutter test test/unit/ --reporter=expanded
        log_success "Unit тесты завершены"
    else
        log_warning "Папка unit тестов не найдена"
    fi
}

# Запуск widget тестов
run_widget_tests() {
    log_info "Запуск widget тестов..."
    
    if [ -f "test/widget_tests.dart" ]; then
        flutter test test/widget_tests.dart --reporter=expanded
        log_success "Widget тесты завершены"
    else
        log_warning "Файл widget тестов не найден"
    fi
}

# Запуск интеграционных тестов
run_integration_tests() {
    log_info "Запуск интеграционных тестов..."
    
    if [ -f "test/integration_tests.dart" ]; then
        flutter test test/integration_tests.dart --reporter=expanded
        log_success "Интеграционные тесты завершены"
    else
        log_warning "Файл интеграционных тестов не найден"
    fi
}

# Запуск платформенных тестов
run_platform_tests() {
    log_info "Запуск платформенных тестов..."
    
    if [ -f "test/platform_tests.dart" ]; then
        flutter test test/platform_tests.dart --reporter=expanded
        log_success "Платформенные тесты завершены"
    else
        log_warning "Файл платформенных тестов не найден"
    fi
}

# Запуск всех тестов
run_all_tests() {
    log_info "Запуск всех тестов..."
    
    # Сначала unit тесты
    run_unit_tests
    
    # Затем widget тесты
    run_widget_tests
    
    # Затем интеграционные тесты
    run_integration_tests
    
    # И наконец платформенные тесты
    run_platform_tests
    
    log_success "Все тесты завершены!"
}

# Запуск тестов с покрытием
run_tests_with_coverage() {
    log_info "Запуск тестов с покрытием..."
    
    # Создаем папку для отчетов
    mkdir -p coverage
    
    # Запускаем все тесты с покрытием
    flutter test --coverage --reporter=expanded
    
    # Генерируем HTML отчет
    if command -v genhtml &> /dev/null; then
        genhtml coverage/lcov.info -o coverage/html
        log_success "HTML отчет сгенерирован в coverage/html/"
    else
        log_warning "genhtml не установлен. Установите lcov для генерации HTML отчетов."
    fi
    
    log_success "Тесты с покрытием завершены"
}

# Запуск тестов в watch режиме
run_tests_watch() {
    log_info "Запуск тестов в watch режиме..."
    
    flutter test --watch --reporter=expanded
}

# Запуск тестов для конкретной платформы
run_platform_specific_tests() {
    local platform=$1
    
    case $platform in
        "android")
            log_info "Запуск тестов для Android..."
            flutter test --platform=android --reporter=expanded
            ;;
        "ios")
            log_info "Запуск тестов для iOS..."
            flutter test --platform=ios --reporter=expanded
            ;;
        "web")
            log_info "Запуск тестов для Web..."
            flutter test --platform=web --reporter=expanded
            ;;
        *)
            log_error "Неизвестная платформа: $platform"
            log_info "Доступные платформы: android, ios, web"
            exit 1
            ;;
    esac
    
    log_success "Тесты для $platform завершены"
}

# Проверка качества кода
run_code_analysis() {
    log_info "Запуск анализа качества кода..."
    
    # Анализ Dart кода
    flutter analyze
    
    # Проверка форматирования
    flutter format --dry-run .
    
    log_success "Анализ качества кода завершен"
}

# Основная функция
main() {
    local command=${1:-"all"}
    
    log_info "🚀 MyModus Test Runner"
    log_info "Команда: $command"
    
    # Проверяем зависимости
    check_dependencies
    
    # Очищаем проект
    clean_project
    
    # Генерируем моки
    generate_mocks
    
    case $command in
        "unit")
            run_unit_tests
            ;;
        "widget")
            run_widget_tests
            ;;
        "integration")
            run_integration_tests
            ;;
        "platform")
            run_platform_tests
            ;;
        "coverage")
            run_tests_with_coverage
            ;;
        "watch")
            run_tests_watch
            ;;
        "android"|"ios"|"web")
            run_platform_specific_tests $command
            ;;
        "analyze")
            run_code_analysis
            ;;
        "all")
            run_all_tests
            ;;
        "help"|"-h"|"--help")
            show_help
            ;;
        *)
            log_error "Неизвестная команда: $command"
            show_help
            exit 1
            ;;
    esac
}

# Показать справку
show_help() {
    echo "MyModus Test Runner - Скрипт для запуска тестов"
    echo ""
    echo "Использование: $0 [команда]"
    echo ""
    echo "Команды:"
    echo "  all          - Запустить все тесты (по умолчанию)"
    echo "  unit         - Запустить только unit тесты"
    echo "  widget       - Запустить только widget тесты"
    echo "  integration  - Запустить только интеграционные тесты"
    echo "  platform     - Запустить только платформенные тесты"
    echo "  coverage     - Запустить тесты с покрытием"
    echo "  watch        - Запустить тесты в watch режиме"
    echo "  android      - Запустить тесты для Android"
    echo "  ios          - Запустить тесты для iOS"
    echo "  web          - Запустить тесты для Web"
    echo "  analyze      - Запустить анализ качества кода"
    echo "  help         - Показать эту справку"
    echo ""
    echo "Примеры:"
    echo "  $0                    # Запустить все тесты"
    echo "  $0 widget            # Запустить только widget тесты"
    echo "  $0 coverage          # Запустить тесты с покрытием"
    echo "  $0 android           # Запустить тесты для Android"
}

# Запуск скрипта
main "$@"
