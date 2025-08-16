#!/bin/bash

# MyModus Full Setup Script
# Этот скрипт настраивает и запускает полную инфраструктуру MyModus

set -e

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Функции для вывода
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Проверка зависимостей
check_dependencies() {
    print_info "Проверка зависимостей..."
    
    local missing_deps=()
    
    # Проверяем Docker
    if ! command -v docker &> /dev/null; then
        missing_deps+=("docker")
    fi
    
    # Проверяем Docker Compose
    if ! command -v docker-compose &> /dev/null; then
        missing_deps+=("docker-compose")
    fi
    
    # Проверяем Git
    if ! command -v git &> /dev/null; then
        missing_deps+=("git")
    fi
    
    # Проверяем Node.js (для смарт-контрактов)
    if ! command -v node &> /dev/null; then
        missing_deps+=("node")
    fi
    
    # Проверяем Flutter
    if ! command -v flutter &> /dev/null; then
        missing_deps+=("flutter")
    fi
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        print_error "Отсутствуют зависимости: ${missing_deps[*]}"
        print_info "Установите их и запустите скрипт снова"
        exit 1
    fi
    
    print_success "Все зависимости установлены"
}

# Создание .env файла
create_env_file() {
    print_info "Создание .env файла..."
    
    if [ ! -f .env ]; then
        cat > .env << EOF
# MyModus Environment Configuration

# Database
DATABASE_URL=postgresql://mymodus_user:mymodus_password@localhost:5432/mymodus
POSTGRES_USER=mymodus_user
POSTGRES_PASSWORD=mymodus_password
POSTGRES_DB=mymodus

# Redis
REDIS_URL=redis://:mymodus_redis_password@localhost:6379
REDIS_PASSWORD=mymodus_redis_password

# JWT
JWT_SECRET=$(openssl rand -hex 32)
JWT_EXPIRES_IN=7d

# OpenAI
OPENAI_API_KEY=your_openai_api_key_here

# Web3
ETHEREUM_RPC_URL=http://localhost:8545
POLYGON_RPC_URL=https://polygon-rpc.com
BSC_RPC_URL=https://bsc-dataseed.binance.org

# IPFS
IPFS_API_URL=http://localhost:5001
IPFS_GATEWAY_URL=http://localhost:8080/ipfs

# Scraping
SCRAPE_DELAY_MS=2000
SCRAPE_INTERVAL_HOURS=6

# Server
PORT=8080
HOST=0.0.0.0
NODE_ENV=development

# Monitoring
PROMETHEUS_PORT=9090
GRAFANA_PORT=3001
ELASTICSEARCH_PORT=9200
KIBANA_PORT=5601
EOF
        print_success ".env файл создан"
    else
        print_warning ".env файл уже существует"
    fi
}

# Настройка смарт-контрактов
setup_smart_contracts() {
    print_info "Настройка смарт-контрактов..."
    
    cd smart-contracts
    
    # Устанавливаем зависимости
    if [ ! -d "node_modules" ]; then
        print_info "Установка npm зависимостей..."
        npm install
    fi
    
    # Компилируем контракты
    print_info "Компиляция смарт-контрактов..."
    npx hardhat compile
    
    # Деплоим в локальную сеть (если запущена)
    if curl -s http://localhost:8545 > /dev/null; then
        print_info "Деплой смарт-контрактов в локальную сеть..."
        npx hardhat run scripts/deploy.js --network localhost
    else
        print_warning "Локальная Ethereum сеть не запущена. Запустите Docker Compose сначала"
    fi
    
    cd ..
}

# Настройка Flutter frontend
setup_flutter_frontend() {
    print_info "Настройка Flutter frontend..."
    
    cd frontend
    
    # Получаем зависимости
    if [ ! -d ".dart_tool" ]; then
        print_info "Получение Flutter зависимостей..."
        flutter pub get
    fi
    
    # Собираем web версию
    print_info "Сборка Flutter web версии..."
    flutter build web --release
    
    cd ..
}

# Создание необходимых директорий
create_directories() {
    print_info "Создание необходимых директорий..."
    
    local dirs=(
        "backups"
        "logs"
        "monitoring/grafana/dashboards"
        "monitoring/grafana/datasources"
        "ssl"
        "web"
    )
    
    for dir in "${dirs[@]}"; do
        if [ ! -d "$dir" ]; then
            mkdir -p "$dir"
            print_info "Создана директория: $dir"
        fi
    done
}

# Создание конфигурационных файлов мониторинга
create_monitoring_configs() {
    print_info "Создание конфигураций мониторинга..."
    
    # Prometheus конфигурация
    cat > monitoring/prometheus.yml << EOF
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  # - "first_rules.yml"
  # - "second_rules.yml"

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'mymodus-backend'
    static_configs:
      - targets: ['backend:8080']
    metrics_path: '/metrics'
    scrape_interval: 5s

  - job_name: 'postgres'
    static_configs:
      - targets: ['postgres:5432']
    metrics_path: '/metrics'

  - job_name: 'redis'
    static_configs:
      - targets: ['redis:6379']
    metrics_path: '/metrics'
EOF

    # Grafana datasource
    cat > monitoring/grafana/datasources/prometheus.yml << EOF
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
EOF

    # Grafana dashboard
    cat > monitoring/grafana/dashboards/mymodus-dashboard.json << EOF
{
  "dashboard": {
    "id": null,
    "title": "MyModus Dashboard",
    "tags": ["mymodus"],
    "timezone": "browser",
    "panels": [],
    "time": {
      "from": "now-6h",
      "to": "now"
    },
    "timepicker": {},
    "templating": {
      "list": []
    },
    "annotations": {
      "list": []
    },
    "refresh": "5s",
    "schemaVersion": 16,
    "version": 0,
    "links": []
  },
  "overwrite": true
}
EOF

    print_success "Конфигурации мониторинга созданы"
}

# Создание Nginx конфигурации
create_nginx_config() {
    print_info "Создание Nginx конфигурации..."
    
    cat > nginx.conf << EOF
events {
    worker_connections 1024;
}

http {
    upstream backend {
        server backend:8080;
    }
    
    upstream frontend {
        server frontend:80;
    }
    
    # Rate limiting
    limit_req_zone \$binary_remote_addr zone=api:10m rate=10r/s;
    limit_req_zone \$binary_remote_addr zone=web:10m rate=30r/s;
    
    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss application/json;
    
    # Security headers
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
    add_header Referrer-Policy "strict-origin-when-cross-origin";
    
    server {
        listen 80;
        server_name localhost;
        
        # Redirect to HTTPS in production
        # return 301 https://\$server_name\$request_uri;
        
        # API endpoints
        location /api/ {
            limit_req zone=api burst=20 nodelay;
            proxy_pass http://backend;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto \$scheme;
        }
        
        # Web interface
        location / {
            limit_req zone=web burst=50 nodelay;
            proxy_pass http://frontend;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto \$scheme;
        }
        
        # Health check
        location /health {
            access_log off;
            return 200 "healthy\n";
            add_header Content-Type text/plain;
        }
    }
    
    # HTTPS configuration (uncomment in production)
    # server {
    #     listen 443 ssl http2;
    #     server_name localhost;
    #     
    #     ssl_certificate /etc/nginx/ssl/cert.pem;
    #     ssl_certificate_key /etc/nginx/ssl/key.pem;
    #     
    #     # ... rest of HTTPS config
    # }
}
EOF

    print_success "Nginx конфигурация создана"
}

# Создание скрипта резервного копирования
create_backup_script() {
    print_info "Создание скрипта резервного копирования..."
    
    cat > scripts/backup.sh << 'EOF'
#!/bin/bash

# MyModus Backup Script

set -e

BACKUP_DIR="/backups"
DATE=$(date +%Y%m%d_%H%M%S)
POSTGRES_HOST="postgres"
POSTGRES_USER="mymodus_user"
POSTGRES_PASSWORD="mymodus_password"
POSTGRES_DB="mymodus"

# Создаем директорию для бэкапа
mkdir -p "$BACKUP_DIR"

# Бэкап PostgreSQL
echo "Creating PostgreSQL backup..."
PGPASSWORD="$POSTGRES_PASSWORD" pg_dump -h "$POSTGRES_HOST" -U "$POSTGRES_USER" -d "$POSTGRES_DB" > "$BACKUP_DIR/postgres_$DATE.sql"

# Бэкап Redis (если доступен)
echo "Creating Redis backup..."
redis-cli -h redis -a mymodus_redis_password --rdb "$BACKUP_DIR/redis_$DATE.rdb" || echo "Redis backup failed"

# Создаем архив
echo "Creating backup archive..."
cd "$BACKUP_DIR"
tar -czf "mymodus_backup_$DATE.tar.gz" "postgres_$DATE.sql" "redis_$DATE.rdb" 2>/dev/null || echo "Archive creation failed"

# Удаляем временные файлы
rm -f "postgres_$DATE.sql" "redis_$DATE.rdb"

echo "Backup completed: mymodus_backup_$DATE.tar.gz"

# Удаляем старые бэкапы (оставляем последние 7)
find "$BACKUP_DIR" -name "mymodus_backup_*.tar.gz" -mtime +7 -delete
EOF

    chmod +x scripts/backup.sh
    print_success "Скрипт резервного копирования создан"
}

# Запуск Docker Compose
start_services() {
    print_info "Запуск сервисов..."
    
    # Останавливаем существующие контейнеры
    docker-compose -f docker-compose.full.yml down
    
    # Запускаем все сервисы
    docker-compose -f docker-compose.full.yml up -d
    
    print_success "Сервисы запущены"
}

# Ожидание готовности сервисов
wait_for_services() {
    print_info "Ожидание готовности сервисов..."
    
    local services=(
        "postgres:5432"
        "redis:6379"
        "backend:8080"
        "frontend:80"
    )
    
    for service in "${services[@]}"; do
        local host=$(echo $service | cut -d: -f1)
        local port=$(echo $service | cut -d: -f2)
        
        print_info "Ожидание $host:$port..."
        
        while ! nc -z $host $port 2>/dev/null; do
            sleep 2
        done
        
        print_success "$host:$port готов"
    done
}

# Инициализация базы данных
init_database() {
    print_info "Инициализация базы данных..."
    
    # Ждем готовности PostgreSQL
    sleep 10
    
    # Запускаем миграции
    docker-compose -f docker-compose.full.yml exec -T postgres psql -U mymodus_user -d mymodus -c "
        CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\";
        CREATE EXTENSION IF NOT EXISTS \"pg_trgm\";
    "
    
    print_success "База данных инициализирована"
}

# Проверка работоспособности
health_check() {
    print_info "Проверка работоспособности..."
    
    local endpoints=(
        "http://localhost:8080/health"
        "http://localhost:3000"
        "http://localhost:9090"
        "http://localhost:3001"
    )
    
    for endpoint in "${endpoints[@]}"; do
        if curl -f -s "$endpoint" > /dev/null; then
            print_success "$endpoint доступен"
        else
            print_error "$endpoint недоступен"
        fi
    done
}

# Основная функция
main() {
    print_info "Запуск полной настройки MyModus..."
    
    # Проверяем зависимости
    check_dependencies
    
    # Создаем необходимые файлы и директории
    create_env_file
    create_directories
    create_monitoring_configs
    create_nginx_config
    create_backup_script
    
    # Настраиваем компоненты
    setup_smart_contracts
    setup_flutter_frontend
    
    # Запускаем сервисы
    start_services
    
    # Ждем готовности
    wait_for_services
    
    # Инициализируем БД
    init_database
    
    # Проверяем работоспособность
    health_check
    
    print_success "MyModus успешно настроен и запущен!"
    print_info ""
    print_info "Доступные сервисы:"
    print_info "  - Backend API: http://localhost:8080"
    print_info "  - Frontend: http://localhost:3000"
    print_info "  - Prometheus: http://localhost:9090"
    print_info "  - Grafana: http://localhost:3001 (admin/admin)"
    print_info "  - Elasticsearch: http://localhost:9200"
    print_info "  - Kibana: http://localhost:5601"
    print_info ""
    print_info "Для остановки: docker-compose -f docker-compose.full.yml down"
    print_info "Для просмотра логов: docker-compose -f docker-compose.full.yml logs -f"
}

# Обработка ошибок
trap 'print_error "Произошла ошибка. Проверьте логи выше."' ERR

# Запуск основной функции
main "$@"
