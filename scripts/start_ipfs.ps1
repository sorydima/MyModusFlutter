# MyModus IPFS Infrastructure Startup Script for Windows
# Скрипт для запуска IPFS узла, кластера и связанных сервисов

param(
    [Parameter(Position=0)]
    [string]$Command = "start"
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
    
    if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
        Write-Error "Docker не установлен. Установите Docker Desktop."
        exit 1
    }
    
    if (-not (Get-Command docker-compose -ErrorAction SilentlyContinue)) {
        Write-Error "Docker Compose не установлен. Установите Docker Compose."
        exit 1
    }
    
    Write-Success "Все зависимости установлены"
}

# Проверка статуса Docker
function Test-DockerStatus {
    Write-Info "Проверка статуса Docker..."
    
    try {
        docker info | Out-Null
        Write-Success "Docker запущен"
    } catch {
        Write-Error "Docker не запущен. Запустите Docker Desktop."
        exit 1
    }
}

# Создание необходимых директорий
function New-Directories {
    Write-Info "Создание необходимых директорий..."
    
    $directories = @(
        "ipfs-data",
        "ipfs-staging", 
        "cluster-data",
        "prometheus-data",
        "logs"
    )
    
    foreach ($dir in $directories) {
        if (-not (Test-Path $dir)) {
            New-Item -ItemType Directory -Path $dir | Out-Null
        }
    }
    
    Write-Success "Директории созданы"
}

# Генерация конфигурационных файлов
function New-Configs {
    Write-Info "Генерация конфигурационных файлов..."
    
    # IPFS конфигурация
    if (-not (Test-Path "ipfs-config")) {
        New-Item -ItemType Directory -Path "ipfs-config" | Out-Null
        Write-Info "IPFS конфигурация будет создана автоматически при первом запуске"
    }
    
    # Cluster конфигурация
    if (-not (Test-Path "cluster-config")) {
        New-Item -ItemType Directory -Path "cluster-config" | Out-Null
        
        $clusterConfig = @"
{
  "cluster": {
    "id": "mymodus-cluster",
    "private_key": "generated-key-will-be-here",
    "secret": "your-cluster-secret-here"
  },
  "consensus": {
    "crdt": {
      "cluster_name": "mymodus-cluster",
      "trusted_peers": []
    }
  },
  "ipfs_connector": {
    "ipfshttp": {
      "node_multiaddress": "/dns4/ipfs-node/tcp/5001/http"
    }
  },
  "monitor": {
    "monitoring_interval": "2s"
  }
}
"@
        
        $clusterConfig | Out-File -FilePath "cluster-config/service.json" -Encoding UTF8
        Write-Info "Cluster конфигурация создана"
    }
    
    Write-Success "Конфигурационные файлы сгенерированы"
}

# Запуск IPFS инфраструктуры
function Start-IPFSInfrastructure {
    Write-Info "Запуск IPFS инфраструктуры..."
    
    # Остановка существующих контейнеров
    docker-compose -f docker-compose.ipfs.yml down 2>$null
    
    # Запуск сервисов
    docker-compose -f docker-compose.ipfs.yml up -d
    
    Write-Success "IPFS инфраструктура запущена"
}

# Ожидание готовности сервисов
function Wait-ForServices {
    Write-Info "Ожидание готовности сервисов..."
    
    # IPFS Node
    Write-Info "Ожидание готовности IPFS узла..."
    do {
        try {
            $response = Invoke-WebRequest -Uri "http://localhost:5001/api/v0/version" -UseBasicParsing -TimeoutSec 5
            break
        } catch {
            Write-Host "." -NoNewline
            Start-Sleep -Seconds 2
        }
    } while ($true)
    Write-Host ""
    Write-Success "IPFS узел готов"
    
    # IPFS Gateway
    Write-Info "Ожидание готовности IPFS Gateway..."
    do {
        try {
            $response = Invoke-WebRequest -Uri "http://localhost:8080/ipfs/QmUNLLsPACCz1vLxQVkXqqLX5R1X345qqfHbsf67hvA3Nn" -UseBasicParsing -TimeoutSec 5
            break
        } catch {
            Write-Host "." -NoNewline
            Start-Sleep -Seconds 2
        }
    } while ($true)
    Write-Host ""
    Write-Success "IPFS Gateway готов"
    
    # IPFS Dashboard
    Write-Info "Ожидание готовности IPFS Dashboard..."
    do {
        try {
            $response = Invoke-WebRequest -Uri "http://localhost:5000" -UseBasicParsing -TimeoutSec 5
            break
        } catch {
            Write-Host "." -NoNewline
            Start-Sleep -Seconds 2
        }
    } while ($true)
    Write-Host ""
    Write-Success "IPFS Dashboard готов"
    
    # Prometheus
    Write-Info "Ожидание готовности Prometheus..."
    do {
        try {
            $response = Invoke-WebRequest -Uri "http://localhost:9090" -UseBasicParsing -TimeoutSec 5
            break
        } catch {
            Write-Host "." -NoNewline
            Start-Sleep -Seconds 2
        }
    } while ($true)
    Write-Host ""
    Write-Success "Prometheus готов"
}

# Проверка статуса сервисов
function Test-ServicesStatus {
    Write-Info "Проверка статуса сервисов..."
    
    Write-Host ""
    Write-Host "=== Статус IPFS сервисов ===" -ForegroundColor $White
    docker-compose -f docker-compose.ipfs.yml ps
    
    Write-Host ""
    Write-Host "=== IPFS Node информация ===" -ForegroundColor $White
    try {
        $version = Invoke-WebRequest -Uri "http://localhost:5001/api/v0/version" -UseBasicParsing
        $version.Content | ConvertFrom-Json | ConvertTo-Json
    } catch {
        Write-Host "Не удалось получить информацию о версии" -ForegroundColor $Yellow
    }
    
    Write-Host ""
    Write-Host "=== IPFS Gateway статус ===" -ForegroundColor $White
    try {
        $health = Invoke-WebRequest -Uri "http://localhost:8080/health" -UseBasicParsing
        $health.Content | ConvertFrom-Json | ConvertTo-Json
    } catch {
        Write-Host "Не удалось получить статус Gateway" -ForegroundColor $Yellow
    }
}

# Показ информации о доступе
function Show-AccessInfo {
    Write-Host ""
    Write-Host "=== Доступ к сервисам ===" -ForegroundColor $White
    Write-Host "IPFS Node API:     http://localhost:5001" -ForegroundColor $White
    Write-Host "IPFS Gateway:      http://localhost:8080" -ForegroundColor $White
    Write-Host "IPFS Dashboard:    http://localhost:5000" -ForegroundColor $White
    Write-Host "IPFS Cluster:      http://localhost:9094" -ForegroundColor $White
    Write-Host "Prometheus:        http://localhost:9090" -ForegroundColor $White
    Write-Host "Nginx Gateway:     http://localhost:8081" -ForegroundColor $White
    
    Write-Host ""
    Write-Host "=== Полезные команды ===" -ForegroundColor $White
    Write-Host "Проверить статус:  docker-compose -f docker-compose.ipfs.yml ps" -ForegroundColor $White
    Write-Host "Просмотр логов:    docker-compose -f docker-compose.ipfs.yml logs -f" -ForegroundColor $White
    Write-Host "Остановить:        docker-compose -f docker-compose.ipfs.yml down" -ForegroundColor $White
    Write-Host ""
}

# Основная функция
function Main {
    Write-Host "🚀 MyModus IPFS Infrastructure Startup" -ForegroundColor $Green
    Write-Host "======================================" -ForegroundColor $Green
    
    # Проверки
    Test-Dependencies
    Test-DockerStatus
    
    # Подготовка
    New-Directories
    New-Configs
    
    # Запуск
    Start-IPFSInfrastructure
    Wait-ForServices
    
    # Проверка
    Test-ServicesStatus
    Show-AccessInfo
    
    Write-Success "IPFS инфраструктура успешно запущена!"
    Write-Host ""
    Write-Host "Теперь вы можете использовать IPFS в MyModus!" -ForegroundColor $Green
}

# Обработка аргументов командной строки
switch ($Command) {
    "start" {
        Main
    }
    "stop" {
        Write-Info "Остановка IPFS инфраструктуры..."
        docker-compose -f docker-compose.ipfs.yml down
        Write-Success "IPFS инфраструктура остановлена"
    }
    "restart" {
        Write-Info "Перезапуск IPFS инфраструктуры..."
        docker-compose -f docker-compose.ipfs.yml restart
        Write-Success "IPFS инфраструктура перезапущена"
    }
    "status" {
        Test-ServicesStatus
    }
    "logs" {
        docker-compose -f docker-compose.ipfs.yml logs -f
    }
    "clean" {
        Write-Warning "Очистка всех данных IPFS..."
        docker-compose -f docker-compose.ipfs.yml down -v
        Remove-Item -Path "ipfs-data", "ipfs-staging", "cluster-data", "prometheus-data" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Success "Данные IPFS очищены"
    }
    default {
        Write-Host "Использование: .\start_ipfs.ps1 {start|stop|restart|status|logs|clean}" -ForegroundColor $White
        Write-Host "  start   - Запустить IPFS инфраструктуру" -ForegroundColor $White
        Write-Host "  stop    - Остановить IPFS инфраструктуру" -ForegroundColor $White
        Write-Host "  restart - Перезапустить IPFS инфраструктуру" -ForegroundColor $White
        Write-Host "  status  - Показать статус сервисов" -ForegroundColor $White
        Write-Host "  logs    - Показать логи" -ForegroundColor $White
        Write-Host "  clean   - Очистить все данные" -ForegroundColor $White
        exit 1
    }
}
