# MyModus Test Runner Script for Windows
# Запуск всех тестов для Flutter приложения

param(
    [Parameter(Position=0)]
    [string]$Command = "all"
)

# Цвета для вывода
$Red = "Red"
$Green = "Green"
$Yellow = "Yellow"
$Blue = "Blue"
$White = "White"

# Функции для логирования
function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor $Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor $Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor $Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor $Red
}

# Проверка зависимостей
function Test-Dependencies {
    Write-Info "Проверка зависимостей..."
    
    if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
        Write-Error "Flutter не установлен. Установите Flutter SDK."
        exit 1
    }
    
    if (-not (Get-Command dart -ErrorAction SilentlyContinue)) {
        Write-Error "Dart не установлен. Установите Dart SDK."
        exit 1
    }
    
    Write-Success "Все зависимости установлены"
}

# Очистка проекта
function Clear-Project {
    Write-Info "Очистка проекта..."
    
    flutter clean
    flutter pub get
    
    Write-Success "Проект очищен"
}

# Генерация моков
function Generate-Mocks {
    Write-Info "Генерация моков для тестов..."
    
    if (Test-Path "test/widget_tests.mocks.dart") {
        Remove-Item "test/widget_tests.mocks.dart"
    }
    
    if (Test-Path "test/integration_tests.mocks.dart") {
        Remove-Item "test/integration_tests.mocks.dart"
    }
    
    flutter packages pub run build_runner build --delete-conflicting-outputs
    
    Write-Success "Моки сгенерированы"
}

# Запуск unit тестов
function Run-UnitTests {
    Write-Info "Запуск unit тестов..."
    
    if (Test-Path "test/unit") {
        flutter test test/unit/ --reporter=expanded
        Write-Success "Unit тесты завершены"
    } else {
        Write-Warning "Папка unit тестов не найдена"
    }
}

# Запуск widget тестов
function Run-WidgetTests {
    Write-Info "Запуск widget тестов..."
    
    if (Test-Path "test/widget_tests.dart") {
        flutter test test/widget_tests.dart --reporter=expanded
        Write-Success "Widget тесты завершены"
    } else {
        Write-Warning "Файл widget тестов не найден"
    }
}

# Запуск интеграционных тестов
function Run-IntegrationTests {
    Write-Info "Запуск интеграционных тестов..."
    
    if (Test-Path "test/integration_tests.dart") {
        flutter test test/integration_tests.dart --reporter=expanded
        Write-Success "Интеграционные тесты завершены"
    } else {
        Write-Warning "Файл интеграционных тестов не найден"
    }
}

# Запуск платформенных тестов
function Run-PlatformTests {
    Write-Info "Запуск платформенных тестов..."
    
    if (Test-Path "test/platform_tests.dart") {
        flutter test test/platform_tests.dart --reporter=expanded
        Write-Success "Платформенные тесты завершены"
    } else {
        Write-Warning "Файл платформенных тестов не найден"
    }
}

# Запуск всех тестов
function Run-AllTests {
    Write-Info "Запуск всех тестов..."
    
    # Сначала unit тесты
    Run-UnitTests
    
    # Затем widget тесты
    Run-WidgetTests
    
    # Затем интеграционные тесты
    Run-IntegrationTests
    
    # И наконец платформенные тесты
    Run-PlatformTests
    
    Write-Success "Все тесты завершены!"
}

# Запуск тестов с покрытием
function Run-TestsWithCoverage {
    Write-Info "Запуск тестов с покрытием..."
    
    # Создаем папку для отчетов
    if (-not (Test-Path "coverage")) {
        New-Item -ItemType Directory -Path "coverage"
    }
    
    # Запускаем все тесты с покрытием
    flutter test --coverage --reporter=expanded
    
    Write-Success "Тесты с покрытием завершены"
}

# Запуск тестов в watch режиме
function Run-TestsWatch {
    Write-Info "Запуск тестов в watch режиме..."
    
    flutter test --watch --reporter=expanded
}

# Запуск тестов для конкретной платформы
function Run-PlatformSpecificTests {
    param([string]$Platform)
    
    switch ($Platform) {
        "android" {
            Write-Info "Запуск тестов для Android..."
            flutter test --platform=android --reporter=expanded
        }
        "ios" {
            Write-Info "Запуск тестов для iOS..."
            flutter test --platform=ios --reporter=expanded
        }
        "web" {
            Write-Info "Запуск тестов для Web..."
            flutter test --platform=web --reporter=expanded
        }
        default {
            Write-Error "Неизвестная платформа: $Platform"
            Write-Info "Доступные платформы: android, ios, web"
            exit 1
        }
    }
    
    Write-Success "Тесты для $Platform завершены"
}

# Проверка качества кода
function Run-CodeAnalysis {
    Write-Info "Запуск анализа качества кода..."
    
    # Анализ Dart кода
    flutter analyze
    
    # Проверка форматирования
    flutter format --dry-run .
    
    Write-Success "Анализ качества кода завершен"
}

# Показать справку
function Show-Help {
    Write-Host "MyModus Test Runner - Скрипт для запуска тестов" -ForegroundColor $White
    Write-Host ""
    Write-Host "Использование: .\run_tests.ps1 [команда]" -ForegroundColor $White
    Write-Host ""
    Write-Host "Команды:" -ForegroundColor $White
    Write-Host "  all          - Запустить все тесты (по умолчанию)" -ForegroundColor $White
    Write-Host "  unit         - Запустить только unit тесты" -ForegroundColor $White
    Write-Host "  widget       - Запустить только widget тесты" -ForegroundColor $White
    Write-Host "  integration  - Запустить только интеграционные тесты" -ForegroundColor $White
    Write-Host "  platform     - Запустить только платформенные тесты" -ForegroundColor $White
    Write-Host "  coverage     - Запустить тесты с покрытием" -ForegroundColor $White
    Write-Host "  watch        - Запустить тесты в watch режиме" -ForegroundColor $White
    Write-Host "  android      - Запустить тесты для Android" -ForegroundColor $White
    Write-Host "  ios          - Запустить тесты для iOS" -ForegroundColor $White
    Write-Host "  web          - Запустить тесты для Web" -ForegroundColor $White
    Write-Host "  analyze      - Запустить анализ качества кода" -ForegroundColor $White
    Write-Host "  help         - Показать эту справку" -ForegroundColor $White
    Write-Host ""
    Write-Host "Примеры:" -ForegroundColor $White
    Write-Host "  .\run_tests.ps1                    # Запустить все тесты" -ForegroundColor $White
    Write-Host "  .\run_tests.ps1 widget            # Запустить только widget тесты" -ForegroundColor $White
    Write-Host "  .\run_tests.ps1 coverage          # Запустить тесты с покрытием" -ForegroundColor $White
    Write-Host "  .\run_tests.ps1 android           # Запустить тесты для Android" -ForegroundColor $White
}

# Основная функция
function Main {
    Write-Info "🚀 MyModus Test Runner"
    Write-Info "Команда: $Command"
    
    # Проверяем зависимости
    Test-Dependencies
    
    # Очищаем проект
    Clear-Project
    
    # Генерируем моки
    Generate-Mocks
    
    switch ($Command) {
        "unit" { Run-UnitTests }
        "widget" { Run-WidgetTests }
        "integration" { Run-IntegrationTests }
        "platform" { Run-PlatformTests }
        "coverage" { Run-TestsWithCoverage }
        "watch" { Run-TestsWatch }
        "android" { Run-PlatformSpecificTests "android" }
        "ios" { Run-PlatformSpecificTests "ios" }
        "web" { Run-PlatformSpecificTests "web" }
        "analyze" { Run-CodeAnalysis }
        "all" { Run-AllTests }
        "help" { Show-Help }
        "-h" { Show-Help }
        "--help" { Show-Help }
        default {
            Write-Error "Неизвестная команда: $Command"
            Show-Help
            exit 1
        }
    }
}

# Запуск скрипта
Main
