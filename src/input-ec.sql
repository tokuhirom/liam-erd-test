-- ERD生成ツールの動作確認用スキーマ
-- 複数のスキーマと様々なリレーションシップを含む

-- スキーマの作成
CREATE SCHEMA IF NOT EXISTS ecommerce;
CREATE SCHEMA IF NOT EXISTS analytics;
CREATE SCHEMA IF NOT EXISTS auth;

-- デフォルトスキーマ (public) のテーブル
-- システム全体の設定
CREATE TABLE IF NOT EXISTS system_config (
    config_id SERIAL PRIMARY KEY,
    config_key VARCHAR(255) UNIQUE NOT NULL,
    config_value TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 認証スキーマ
-- ユーザーテーブル
CREATE TABLE IF NOT EXISTS auth.users (
    user_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    username VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ユーザープロファイル (1:1 リレーション)
CREATE TABLE IF NOT EXISTS auth.user_profiles (
    profile_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID UNIQUE NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    phone VARCHAR(20),
    birth_date DATE,
    avatar_url TEXT,
    bio TEXT,
    CONSTRAINT fk_profile_user 
        FOREIGN KEY (user_id) 
        REFERENCES auth.users(user_id) 
        ON DELETE CASCADE
);

-- ロールテーブル
CREATE TABLE IF NOT EXISTS auth.roles (
    role_id SERIAL PRIMARY KEY,
    role_name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT
);

-- ユーザーとロールの多対多リレーション
CREATE TABLE IF NOT EXISTS auth.user_roles (
    user_id UUID,
    role_id INTEGER,
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, role_id),
    CONSTRAINT fk_user_roles_user 
        FOREIGN KEY (user_id) 
        REFERENCES auth.users(user_id) 
        ON DELETE CASCADE,
    CONSTRAINT fk_user_roles_role 
        FOREIGN KEY (role_id) 
        REFERENCES auth.roles(role_id) 
        ON DELETE CASCADE
);

-- Eコマーススキーマ
-- カテゴリテーブル（階層構造）
CREATE TABLE IF NOT EXISTS ecommerce.categories (
    category_id SERIAL PRIMARY KEY,
    parent_category_id INTEGER,
    category_name VARCHAR(100) NOT NULL,
    slug VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    sort_order INTEGER DEFAULT 0,
    CONSTRAINT fk_category_parent 
        FOREIGN KEY (parent_category_id) 
        REFERENCES ecommerce.categories(category_id) 
        ON DELETE CASCADE
);

-- 商品テーブル
CREATE TABLE IF NOT EXISTS ecommerce.products (
    product_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sku VARCHAR(100) UNIQUE NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL CHECK (price >= 0),
    cost DECIMAL(10, 2) CHECK (cost >= 0),
    stock_quantity INTEGER DEFAULT 0 CHECK (stock_quantity >= 0),
    weight DECIMAL(8, 3),
    is_active BOOLEAN DEFAULT true,
    created_by UUID,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_product_creator 
        FOREIGN KEY (created_by) 
        REFERENCES auth.users(user_id) 
        ON DELETE SET NULL
);

-- 商品とカテゴリの多対多リレーション
CREATE TABLE IF NOT EXISTS ecommerce.product_categories (
    product_id UUID,
    category_id INTEGER,
    is_primary BOOLEAN DEFAULT false,
    PRIMARY KEY (product_id, category_id),
    CONSTRAINT fk_prod_cat_product 
        FOREIGN KEY (product_id) 
        REFERENCES ecommerce.products(product_id) 
        ON DELETE CASCADE,
    CONSTRAINT fk_prod_cat_category 
        FOREIGN KEY (category_id) 
        REFERENCES ecommerce.categories(category_id) 
        ON DELETE CASCADE
);

-- 商品画像テーブル (1:N リレーション)
CREATE TABLE IF NOT EXISTS ecommerce.product_images (
    image_id SERIAL PRIMARY KEY,
    product_id UUID NOT NULL,
    image_url TEXT NOT NULL,
    alt_text VARCHAR(255),
    is_primary BOOLEAN DEFAULT false,
    sort_order INTEGER DEFAULT 0,
    CONSTRAINT fk_image_product 
        FOREIGN KEY (product_id) 
        REFERENCES ecommerce.products(product_id) 
        ON DELETE CASCADE
);

-- 顧客テーブル
CREATE TABLE IF NOT EXISTS ecommerce.customers (
    customer_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID UNIQUE,
    customer_number VARCHAR(50) UNIQUE NOT NULL,
    company_name VARCHAR(255),
    tax_id VARCHAR(50),
    credit_limit DECIMAL(10, 2) DEFAULT 0,
    CONSTRAINT fk_customer_user 
        FOREIGN KEY (user_id) 
        REFERENCES auth.users(user_id) 
        ON DELETE SET NULL
);

-- 住所テーブル（ポリモーフィックな関連）
CREATE TABLE IF NOT EXISTS ecommerce.addresses (
    address_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    entity_type VARCHAR(50) NOT NULL, -- 'customer', 'order', etc.
    entity_id UUID NOT NULL,
    address_type VARCHAR(20) NOT NULL, -- 'billing', 'shipping'
    street_address_1 VARCHAR(255) NOT NULL,
    street_address_2 VARCHAR(255),
    city VARCHAR(100) NOT NULL,
    state_province VARCHAR(100),
    postal_code VARCHAR(20),
    country_code CHAR(2) NOT NULL,
    is_default BOOLEAN DEFAULT false
);

-- 注文テーブル
CREATE TABLE IF NOT EXISTS ecommerce.orders (
    order_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_number VARCHAR(50) UNIQUE NOT NULL,
    customer_id UUID NOT NULL,
    order_status VARCHAR(50) NOT NULL DEFAULT 'pending',
    payment_status VARCHAR(50) NOT NULL DEFAULT 'unpaid',
    subtotal DECIMAL(10, 2) NOT NULL,
    tax_amount DECIMAL(10, 2) DEFAULT 0,
    shipping_amount DECIMAL(10, 2) DEFAULT 0,
    total_amount DECIMAL(10, 2) NOT NULL,
    currency_code CHAR(3) DEFAULT 'USD',
    notes TEXT,
    ordered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    shipped_at TIMESTAMP,
    delivered_at TIMESTAMP,
    CONSTRAINT fk_order_customer 
        FOREIGN KEY (customer_id) 
        REFERENCES ecommerce.customers(customer_id)
);

-- 注文明細テーブル
CREATE TABLE IF NOT EXISTS ecommerce.order_items (
    order_item_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL,
    product_id UUID NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10, 2) NOT NULL,
    discount_amount DECIMAL(10, 2) DEFAULT 0,
    tax_amount DECIMAL(10, 2) DEFAULT 0,
    total_amount DECIMAL(10, 2) NOT NULL,
    CONSTRAINT fk_order_item_order 
        FOREIGN KEY (order_id) 
        REFERENCES ecommerce.orders(order_id) 
        ON DELETE CASCADE,
    CONSTRAINT fk_order_item_product 
        FOREIGN KEY (product_id) 
        REFERENCES ecommerce.products(product_id)
);

-- レビューテーブル
CREATE TABLE IF NOT EXISTS ecommerce.reviews (
    review_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL,
    customer_id UUID NOT NULL,
    rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
    title VARCHAR(255),
    comment TEXT,
    is_verified_purchase BOOLEAN DEFAULT false,
    helpful_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_review_product 
        FOREIGN KEY (product_id) 
        REFERENCES ecommerce.products(product_id) 
        ON DELETE CASCADE,
    CONSTRAINT fk_review_customer 
        FOREIGN KEY (customer_id) 
        REFERENCES ecommerce.customers(customer_id),
    CONSTRAINT unique_customer_product_review 
        UNIQUE (product_id, customer_id)
);

-- 分析スキーマ
-- ページビューテーブル
CREATE TABLE IF NOT EXISTS analytics.page_views (
    view_id BIGSERIAL PRIMARY KEY,
    session_id UUID NOT NULL,
    user_id UUID,
    page_url TEXT NOT NULL,
    referrer_url TEXT,
    user_agent TEXT,
    ip_address INET,
    country_code CHAR(2),
    viewed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_page_view_user 
        FOREIGN KEY (user_id) 
        REFERENCES auth.users(user_id) 
        ON DELETE SET NULL
);

-- 商品ビュー統計テーブル
CREATE TABLE IF NOT EXISTS analytics.product_stats (
    stat_id SERIAL PRIMARY KEY,
    product_id UUID NOT NULL,
    date DATE NOT NULL,
    view_count INTEGER DEFAULT 0,
    add_to_cart_count INTEGER DEFAULT 0,
    purchase_count INTEGER DEFAULT 0,
    revenue DECIMAL(10, 2) DEFAULT 0,
    CONSTRAINT fk_product_stats_product 
        FOREIGN KEY (product_id) 
        REFERENCES ecommerce.products(product_id) 
        ON DELETE CASCADE,
    CONSTRAINT unique_product_date 
        UNIQUE (product_id, date)
);

-- インデックスの作成
CREATE INDEX idx_users_email ON auth.users(email);
CREATE INDEX idx_users_username ON auth.users(username);
CREATE INDEX idx_products_sku ON ecommerce.products(sku);
CREATE INDEX idx_products_active ON ecommerce.products(is_active) WHERE is_active = true;
CREATE INDEX idx_orders_customer ON ecommerce.orders(customer_id);
CREATE INDEX idx_orders_status ON ecommerce.orders(order_status);
CREATE INDEX idx_orders_ordered_at ON ecommerce.orders(ordered_at);
CREATE INDEX idx_page_views_session ON analytics.page_views(session_id);
CREATE INDEX idx_page_views_viewed_at ON analytics.page_views(viewed_at);
CREATE INDEX idx_addresses_entity ON ecommerce.addresses(entity_type, entity_id);

-- ビューの作成（ERDツールがビューも認識するかテスト）
CREATE OR REPLACE VIEW ecommerce.active_products AS
SELECT 
    p.product_id,
    p.sku,
    p.product_name,
    p.price,
    p.stock_quantity,
    COUNT(DISTINCT r.review_id) as review_count,
    AVG(r.rating) as avg_rating
FROM ecommerce.products p
LEFT JOIN ecommerce.reviews r ON p.product_id = r.product_id
WHERE p.is_active = true
GROUP BY p.product_id, p.sku, p.product_name, p.price, p.stock_quantity;

-- マテリアライズドビューの作成
CREATE MATERIALIZED VIEW analytics.daily_sales_summary AS
SELECT 
    DATE(o.ordered_at) as order_date,
    COUNT(DISTINCT o.order_id) as order_count,
    COUNT(DISTINCT o.customer_id) as customer_count,
    SUM(o.total_amount) as total_revenue,
    AVG(o.total_amount) as avg_order_value
FROM ecommerce.orders o
WHERE o.order_status != 'cancelled'
GROUP BY DATE(o.ordered_at);

-- トリガー関数（更新日時の自動更新）
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- トリガーの作成
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON auth.users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON ecommerce.products
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 複合型の定義
CREATE TYPE ecommerce.order_status_type AS ENUM (
    'pending',
    'confirmed',
    'processing',
    'shipped',
    'delivered',
    'cancelled',
    'refunded'
);

-- ドメインの定義
CREATE DOMAIN ecommerce.positive_decimal AS DECIMAL(10, 2)
    CHECK (VALUE >= 0);

-- コメントの追加（ERDツールが説明を表示するかテスト）
COMMENT ON TABLE auth.users IS 'システムユーザー情報';
COMMENT ON TABLE ecommerce.products IS '商品マスタ';
COMMENT ON TABLE ecommerce.orders IS '注文情報';
COMMENT ON TABLE analytics.page_views IS 'ページビュー追跡データ';
COMMENT ON COLUMN ecommerce.products.sku IS '在庫管理単位（Stock Keeping Unit）';
COMMENT ON COLUMN ecommerce.orders.order_status IS '注文ステータス（pending, confirmed, processing, shipped, delivered, cancelled, refunded）';