-- 008_ai_personal_shopper.sql
-- Создание таблиц для AI-персонального шоппера

-- Таблица пользовательских предпочтений
CREATE TABLE IF NOT EXISTS user_preferences (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  category_preferences JSONB DEFAULT '{}', -- Предпочтения по категориям с весами
  brand_preferences JSONB DEFAULT '{}', -- Предпочитаемые бренды
  price_range JSONB DEFAULT '{"min": 0, "max": 1000000}', -- Диапазон цен в копейках
  size_preferences JSONB DEFAULT '{}', -- Размеры для одежды/обуви
  color_preferences TEXT[] DEFAULT ARRAY[]::TEXT[], -- Предпочитаемые цвета
  style_preferences TEXT[] DEFAULT ARRAY[]::TEXT[], -- Стили (casual, formal, sport, etc.)
  seasonal_preferences JSONB DEFAULT '{}', -- Сезонные предпочтения
  shopping_frequency JSONB DEFAULT '{}', -- Частота покупок по категориям
  budget_monthly INTEGER DEFAULT 0, -- Месячный бюджет в копейках
  preferred_marketplaces TEXT[] DEFAULT ARRAY[]::TEXT[], -- Предпочитаемые площадки
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(user_id)
);

-- Таблица истории просмотров товаров
CREATE TABLE IF NOT EXISTS user_product_views (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  product_id UUID NOT NULL,
  product_title TEXT NOT NULL,
  product_price INTEGER NOT NULL,
  product_category TEXT,
  product_brand TEXT,
  product_source TEXT NOT NULL,
  view_duration INTEGER DEFAULT 0, -- Время просмотра в секундах
  clicked_details BOOLEAN DEFAULT false, -- Перешел ли к детальному просмотру
  added_to_wishlist BOOLEAN DEFAULT false, -- Добавил ли в вишлист
  viewed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Таблица истории покупок (расширенная)
CREATE TABLE IF NOT EXISTS user_purchases (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  product_id UUID NOT NULL,
  product_title TEXT NOT NULL,
  product_price INTEGER NOT NULL,
  product_category TEXT,
  product_brand TEXT,
  product_source TEXT NOT NULL,
  quantity INTEGER DEFAULT 1,
  total_amount INTEGER NOT NULL,
  purchase_satisfaction INTEGER CHECK (purchase_satisfaction >= 1 AND purchase_satisfaction <= 5), -- Оценка покупки
  purchase_reason TEXT, -- Причина покупки (gift, personal, work, etc.)
  purchased_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Таблица избранного/вишлиста
CREATE TABLE IF NOT EXISTS user_wishlist (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  product_id UUID NOT NULL,
  product_title TEXT NOT NULL,
  product_price INTEGER NOT NULL,
  product_category TEXT,
  product_brand TEXT,
  product_source TEXT NOT NULL,
  product_url TEXT NOT NULL,
  product_image_url TEXT,
  priority INTEGER DEFAULT 3 CHECK (priority >= 1 AND priority <= 5), -- Приоритет желания (1-5)
  price_alert_threshold INTEGER, -- Цена для уведомления о скидке
  notes TEXT, -- Заметки пользователя
  added_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(user_id, product_id)
);

-- Таблица AI-рекомендаций
CREATE TABLE IF NOT EXISTS ai_recommendations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  product_id UUID NOT NULL,
  product_title TEXT NOT NULL,
  product_price INTEGER NOT NULL,
  product_category TEXT,
  product_brand TEXT,
  product_source TEXT NOT NULL,
  product_url TEXT NOT NULL,
  product_image_url TEXT,
  recommendation_score DECIMAL(3,2) CHECK (recommendation_score >= 0 AND recommendation_score <= 1), -- Скор от 0 до 1
  recommendation_reasons JSONB DEFAULT '[]', -- Причины рекомендации
  recommendation_type TEXT NOT NULL, -- 'similar', 'trending', 'personal', 'price_drop', etc.
  is_viewed BOOLEAN DEFAULT false,
  is_clicked BOOLEAN DEFAULT false,
  is_purchased BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  expires_at TIMESTAMP WITH TIME ZONE, -- Когда рекомендация теряет актуальность
  UNIQUE(user_id, product_id, recommendation_type, created_at)
);

-- Таблица анализа трендов пользователя
CREATE TABLE IF NOT EXISTS user_trend_analysis (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  analysis_type TEXT NOT NULL, -- 'style_evolution', 'spending_pattern', 'seasonal_trends'
  analysis_data JSONB NOT NULL, -- Результаты анализа
  confidence_score DECIMAL(3,2) CHECK (confidence_score >= 0 AND confidence_score <= 1),
  generated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  valid_until TIMESTAMP WITH TIME ZONE -- Когда анализ устаревает
);

-- Индексы для быстрого поиска
CREATE INDEX IF NOT EXISTS idx_user_preferences_user_id ON user_preferences(user_id);
CREATE INDEX IF NOT EXISTS idx_user_product_views_user_id ON user_product_views(user_id);
CREATE INDEX IF NOT EXISTS idx_user_product_views_product_id ON user_product_views(product_id);
CREATE INDEX IF NOT EXISTS idx_user_product_views_viewed_at ON user_product_views(viewed_at);
CREATE INDEX IF NOT EXISTS idx_user_purchases_user_id ON user_purchases(user_id);
CREATE INDEX IF NOT EXISTS idx_user_purchases_product_id ON user_purchases(product_id);
CREATE INDEX IF NOT EXISTS idx_user_purchases_purchased_at ON user_purchases(purchased_at);
CREATE INDEX IF NOT EXISTS idx_user_wishlist_user_id ON user_wishlist(user_id);
CREATE INDEX IF NOT EXISTS idx_user_wishlist_product_id ON user_wishlist(product_id);
CREATE INDEX IF NOT EXISTS idx_ai_recommendations_user_id ON ai_recommendations(user_id);
CREATE INDEX IF NOT EXISTS idx_ai_recommendations_score ON ai_recommendations(recommendation_score DESC);
CREATE INDEX IF NOT EXISTS idx_ai_recommendations_type ON ai_recommendations(recommendation_type);
CREATE INDEX IF NOT EXISTS idx_ai_recommendations_created_at ON ai_recommendations(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_user_trend_analysis_user_id ON user_trend_analysis(user_id);
CREATE INDEX IF NOT EXISTS idx_user_trend_analysis_type ON user_trend_analysis(analysis_type);

-- Триггеры для автоматического обновления updated_at
CREATE TRIGGER update_user_preferences_updated_at BEFORE UPDATE ON user_preferences
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_wishlist_updated_at BEFORE UPDATE ON user_wishlist
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Функция для автоматического обновления предпочтений на основе активности
CREATE OR REPLACE FUNCTION update_user_preferences_from_activity()
RETURNS TRIGGER AS $$
BEGIN
    -- Обновляем предпочтения на основе просмотров и покупок
    -- Это будет вызываться при добавлении новых записей
    
    -- Увеличиваем вес категории в предпочтениях
    UPDATE user_preferences 
    SET category_preferences = jsonb_set(
        category_preferences,
        ARRAY[COALESCE(NEW.product_category, 'unknown')],
        to_jsonb(COALESCE((category_preferences->>COALESCE(NEW.product_category, 'unknown'))::DECIMAL, 0) + 0.1)
    ),
    updated_at = CURRENT_TIMESTAMP
    WHERE user_id = NEW.user_id;
    
    -- Увеличиваем вес бренда в предпочтениях
    UPDATE user_preferences 
    SET brand_preferences = jsonb_set(
        brand_preferences,
        ARRAY[COALESCE(NEW.product_brand, 'unknown')],
        to_jsonb(COALESCE((brand_preferences->>COALESCE(NEW.product_brand, 'unknown'))::DECIMAL, 0) + 0.1)
    ),
    updated_at = CURRENT_TIMESTAMP
    WHERE user_id = NEW.user_id;
    
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Триггеры для автоматического обновления предпочтений
CREATE TRIGGER update_preferences_from_views AFTER INSERT ON user_product_views
    FOR EACH ROW EXECUTE FUNCTION update_user_preferences_from_activity();

CREATE TRIGGER update_preferences_from_purchases AFTER INSERT ON user_purchases
    FOR EACH ROW EXECUTE FUNCTION update_user_preferences_from_activity();
