#!/bin/bash

# MyModus IPFS Infrastructure Startup Script
# Скрипт для запуска IPFS узла, кластера и связанных сервисов

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
    
    if ! command -v docker &> /dev/null; then
        log_error "Docker не установлен. Установите Docker."
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        log_error "Docker Compose не установлен. Установите Docker Compose."
        exit 1
    fi
    
    log_success "Все зависимости установлены"
}

# Проверка статуса Docker
check_docker_status() {
    log_info "Проверка статуса Docker..."
    
    if ! docker info &> /dev/null; then
        log_error "Docker не запущен. Запустите Docker daemon."
        exit 1
    fi
    
    log_success "Docker запущен"
}

# Создание необходимых директорий
create_directories() {
    log_info "Создание необходимых директорий..."
    
    mkdir -p ipfs-data
    mkdir -p ipfs-staging
    mkdir -p cluster-data
    mkdir -p prometheus-data
    mkdir -p logs
    
    log_success "Директории созданы"
}

# Генерация конфигурационных файлов
generate_configs() {
    log_info "Генерация конфигурационных файлов..."
    
    # IPFS конфигурация
    if [ ! -f "ipfs-config/config" ]; then
        mkdir -p ipfs-config
        log_info "Создание базовой IPFS конфигурации..."
        
        # Здесь можно добавить генерацию IPFS конфигурации
        echo "IPFS конфигурация будет создана автоматически при первом запуске"
    fi
    
    # Cluster конфигурация
    if [ ! -f "cluster-config/service.json" ]; then
        mkdir -p cluster-config
        log_info "Создание базовой Cluster конфигурации..."
        
        cat > cluster-config/service.json << EOF
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
EOF
    fi
    
    log_success "Конфигурационные файлы сгенерированы"
}

# Запуск IPFS инфраструктуры
start_ipfs_infrastructure() {
    log_info "Запуск IPFS инфраструктуры..."
    
    # Остановка существующих контейнеров
    docker-compose -f docker-compose.ipfs.yml down 2>/dev/null || true
    
    # Запуск сервисов
    docker-compose -f docker-compose.ipfs.yml up -d
    
    log_success "IPFS инфраструктура запущена"
}

# Ожидание готовности сервисов
wait_for_services() {
    log_info "Ожидание готовности сервисов..."
    
    # IPFS Node
    log_info "Ожидание готовности IPFS узла..."
    until curl -s http://localhost:5001/api/v0/version > /dev/null 2>&1; do
        echo -n "."
        sleep 2
    done
    echo ""
    log_success "IPFS узел готов"
    
    # IPFS Gateway
    log_info "Ожидание готовности IPFS Gateway..."
    until curl -s http://localhost:8080/ipfs/QmUNLLsPACCz1vLxQVkXqqLX5R1X345qqfHbsf67hvA3Nn > /dev/null 2>&1; do
        echo -n "."
        sleep 2
    done
    echo ""
    log_success "IPFS Gateway готов"
    
    # IPFS Dashboard
    log_info "Ожидание готовности IPFS Dashboard..."
    until curl -s http://localhost:5000 > /dev/null 2>&1; do
        echo -n "."
        sleep 2
    done
    echo ""
    log_success "IPFS Dashboard готов"
    
    # Prometheus
    log_info "Ожидание готовности Prometheus..."
    until curl -s http://localhost:9090 > /dev/null 2>&1; do
        echo -n "."
        sleep 2
    done
    echo ""
    log_success "Prometheus готов"
}

# Проверка статуса сервисов
check_services_status() {
    log_info "Проверка статуса сервисов..."
    
    echo ""
    echo "=== Статус IPFS сервисов ==="
    docker-compose -f docker-compose.ipfs.yml ps
    
    echo ""
    echo "=== IPFS Node информация ==="
    curl -s http://localhost:5001/api/v0/version | jq '.' 2>/dev/null || echo "Не удалось получить информацию о версии"
    
    echo ""
    echo "=== IPFS Gateway статус ==="
    curl -s http://localhost:8080/health | jq '.' 2>/dev/null || echo "Не удалось получить статус Gateway"
    
    echo ""
    echo "=== Cluster статус ==="
    curl -s http://localhost:9094/health | jq '.' 2>/dev/null || echo "Не удалось получить статус Cluster"
}

# Показ информации о доступе
show_access_info() {
    echo ""
    echo "=== Доступ к сервисам ==="
    echo "IPFS Node API:     http://localhost:5001"
    echo "IPFS Gateway:      http://localhost:8080"
    echo "IPFS Dashboard:    http://localhost:5000"
    echo "IPFS Cluster:      http://localhost:9094"
    echo "Prometheus:        http://localhost:9090"
    echo "Nginx Gateway:     http://localhost:8081"
    echo ""
    echo "=== Полезные команды ==="
    echo "Проверить статус:  docker-compose -f docker-compose.ipfs.yml ps"
    echo "Просмотр логов:    docker-compose -f docker-compose.ipfs.yml logs -f"
    echo "Остановить:        docker-compose -f docker-compose.ipfs.yml down"
    echo ""
}

# Основная функция
main() {
    echo "🚀 MyModus IPFS Infrastructure Startup"
    echo "======================================"
    
    # Проверки
    check_dependencies
    check_docker_status
    
    # Подготовка
    create_directories
    generate_configs
    
    # Запуск
    start_ipfs_infrastructure
    wait_for_services
    
    # Проверка
    check_services_status
    show_access_info
    
    log_success "IPFS инфраструктура успешно запущена!"
    echo ""
    echo "Теперь вы можете использовать IPFS в MyModus!"
}

# Обработка аргументов командной строки
case "${1:-start}" in
    "start")
        main
        ;;
    "stop")
        log_info "Остановка IPFS инфраструктуры..."
        docker-compose -f docker-compose.ipfs.yml down
        log_success "IPFS инфраструктура остановлена"
        ;;
    "restart")
        log_info "Перезапуск IPFS инфраструктуры..."
        docker-compose -f docker-compose.ipfs.yml restart
        log_success "IPFS инфраструктура перезапущена"
        ;;
    "status")
        check_services_status
        ;;
    "logs")
        docker-compose -f docker-compose.ipfs.yml logs -f
        ;;
    "clean")
        log_warning "Очистка всех данных IPFS..."
        docker-compose -f docker-compose.ipfs.yml down -v
        rm -rf ipfs-data ipfs-staging cluster-data prometheus-data
        log_success "Данные IPFS очищены"
        ;;
    *)
        echo "Использование: $0 {start|stop|restart|status|logs|clean}"
        echo "  start   - Запустить IPFS инфраструктуру"
        echo "  stop    - Остановить IPFS инфраструктуру"
        echo "  restart - Перезапустить IPFS инфраструктуру"
        echo "  status  - Показать статус сервисов"
        echo "  logs    - Показать логи"
        echo "  clean   - Очистить все данные"
        exit 1
        ;;
esac
