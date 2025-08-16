import 'dart:async';
import 'package:postgres/postgres.dart';
import 'package:logger/logger.dart';
import 'package:dotenv/dotenv.dart';
import 'models.dart';

class DatabaseService {
  static PostgreSQLConnection? _connection;
  static final Logger _logger = Logger();
  
  static Future<PostgreSQLConnection> getConnection() async {
    if (_connection != null && !_connection!.isClosed) {
      return _connection!;
    }
    
    final env = DotEnv()..load();
    final uri = env['DATABASE_URL'] ?? 'postgres://mymodus:mymodus123@localhost:5432/mymodus';
    final uriObj = Uri.parse(uri);
    
    _connection = PostgreSQLConnection(
      uriObj.host,
      uriObj.port,
      uriObj.path.replaceFirst('/', ''),
      username: uriObj.userInfo.split(':').first,
      password: uriObj.userInfo.split(':').last,
      useSSL: false,
    );
    
    await _connection!.open();
    _logger.i('Database connection established');
    return _connection!;
  }

  static Future<void> closeConnection() async {
    if (_connection != null) {
      await _connection!.close();
      _connection = null;
    }
  }

  /// Закрытие соединения (для использования в других сервисах)
  static Future<void> close() async {
    await closeConnection();
  }

  static Future<void> runMigrations() async {
    final conn = await getConnection();
    
    // Users table
    await conn.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        email VARCHAR(255) UNIQUE NOT NULL,
        name VARCHAR(255),
        phone VARCHAR(20),
        password_hash VARCHAR(255) NOT NULL,
        is_active BOOLEAN DEFAULT true,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    ''');

    // Categories table
    await conn.execute('''
      CREATE TABLE IF NOT EXISTS categories (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        name VARCHAR(255) NOT NULL,
        description TEXT,
        icon VARCHAR(255),
        parent_id UUID REFERENCES categories(id),
        product_count INTEGER DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    ''');

    // Products table
    await conn.execute('''
      CREATE TABLE IF NOT EXISTS products (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        title VARCHAR(500) NOT NULL,
        description TEXT,
        price INTEGER NOT NULL,
        old_price INTEGER,
        discount INTEGER,
        image_url VARCHAR(1000) NOT NULL,
        product_url VARCHAR(1000) NOT NULL,
        brand VARCHAR(255),
        category_id UUID REFERENCES categories(id),
        sku VARCHAR(100),
        specifications JSONB,
        stock INTEGER DEFAULT 0,
        rating DECIMAL(3,2) DEFAULT 0,
        review_count INTEGER DEFAULT 0,
        source VARCHAR(50) NOT NULL,
        source_id VARCHAR(255) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(source, source_id)
      );
    ''');

    // Orders table
    await conn.execute('''
      CREATE TABLE IF NOT EXISTS orders (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        user_id UUID REFERENCES users(id) ON DELETE CASCADE,
        total_amount INTEGER NOT NULL,
        discount_amount INTEGER,
        status VARCHAR(50) DEFAULT 'pending',
        payment_method VARCHAR(100),
        shipping_address JSONB,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    ''');

    // Order items table
    await conn.execute('''
      CREATE TABLE IF NOT EXISTS order_items (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
        product_id UUID REFERENCES products(id) ON DELETE CASCADE,
        quantity INTEGER NOT NULL,
        price INTEGER NOT NULL,
        size VARCHAR(50),
        color VARCHAR(50)
      );
    ''');

    // Cart items table
    await conn.execute('''
      CREATE TABLE IF NOT EXISTS cart_items (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        user_id UUID REFERENCES users(id) ON DELETE CASCADE,
        product_id UUID REFERENCES products(id) ON DELETE CASCADE,
        quantity INTEGER NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(user_id, product_id)
      );
    ''');

    // Favorites table
    await conn.execute('''
      CREATE TABLE IF NOT EXISTS favorites (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        user_id UUID REFERENCES users(id) ON DELETE CASCADE,
        product_id UUID REFERENCES products(id) ON DELETE CASCADE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(user_id, product_id)
      );
    ''');

    // Reviews table
    await conn.execute('''
      CREATE TABLE IF NOT EXISTS reviews (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        user_id UUID REFERENCES users(id) ON DELETE CASCADE,
        product_id UUID REFERENCES products(id) ON DELETE CASCADE,
        rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
        comment TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    ''');

    // Scraping jobs table
    await conn.execute('''
      CREATE TABLE IF NOT EXISTS scraping_jobs (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        source VARCHAR(50) NOT NULL,
        status VARCHAR(50) DEFAULT 'pending',
        products_scraped INTEGER DEFAULT 0,
        products_updated INTEGER,
        error TEXT,
        started_at TIMESTAMP,
        completed_at TIMESTAMP,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    ''');

    // Create indexes for better performance
    await conn.execute('CREATE INDEX IF NOT EXISTS idx_products_category ON products(category_id);');
    await conn.execute('CREATE INDEX IF NOT EXISTS idx_products_source ON products(source);');
    await conn.execute('CREATE INDEX IF NOT EXISTS idx_products_brand ON products(brand);');
    await conn.execute('CREATE INDEX IF NOT EXISTS idx_orders_user ON orders(user_id);');
    await conn.execute('CREATE INDEX IF NOT EXISTS idx_cart_user ON cart_items(user_id);');
    await conn.execute('CREATE INDEX IF NOT EXISTS idx_favorites_user ON favorites(user_id);');
    await conn.execute('CREATE INDEX IF NOT EXISTS idx_reviews_product ON reviews(product_id);');
    await conn.execute('CREATE INDEX IF NOT EXISTS idx_scraping_status ON scraping_jobs(status);');

    // Create updated_at trigger function
    await conn.execute('''
      CREATE OR REPLACE FUNCTION update_updated_at_column()
      RETURNS TRIGGER AS $$
      BEGIN
        NEW.updated_at = CURRENT_TIMESTAMP;
        RETURN NEW;
      END;
      $$ language 'plpgsql';
    ''');

    // Add triggers for updated_at
    await conn.execute('''
      CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
      FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
    ''');

    await conn.execute('''
      CREATE TRIGGER update_categories_updated_at BEFORE UPDATE ON categories
      FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
    ''');

    await conn.execute('''
      CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON products
      FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
    ''');

    await conn.execute('''
      CREATE TRIGGER update_orders_updated_at BEFORE UPDATE ON orders
      FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
    ''');

    await conn.execute('''
      CREATE TRIGGER update_cart_items_updated_at BEFORE UPDATE ON cart_items
      FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
    ''');

    print('Database migrations completed successfully');
  }

  static Future<void> seedInitialData() async {
    final conn = await getConnection();
    
    // Check if data already exists
    final result = await conn.execute('SELECT COUNT(*) FROM categories;');
    if ((result.first as List).first == 0) {
      // Insert initial categories
      await conn.execute('''
        INSERT INTO categories (name, description, icon) VALUES 
        ('Одежда', 'Мужская и женская одежда', '👕'),
        ('Обувь', 'Обувь для всей семьи', '👟'),
        ('Электроника', 'Гаджеты и электроника', '📱'),
        ('Дом и сад', 'Товары для дома и сада', '🏠'),
        ('Красота и здоровье', 'Косметика и товары для здоровья', '💄'),
        ('Спорт', 'Товары для спорта и активного отдыха', '⚽'),
        ('Автотовары', 'Все для автомобиля', '🚗'),
        ('Детские товары', 'Товары для детей', '👶');
      ''');
      
      print('Initial categories seeded');
    }
  }
}