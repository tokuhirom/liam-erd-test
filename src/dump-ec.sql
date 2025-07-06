--
-- PostgreSQL database dump
--

-- Dumped from database version 15.13
-- Dumped by pg_dump version 15.13

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: analytics; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA analytics;


ALTER SCHEMA analytics OWNER TO postgres;

--
-- Name: auth; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA auth;


ALTER SCHEMA auth OWNER TO postgres;

--
-- Name: ecommerce; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA ecommerce;


ALTER SCHEMA ecommerce OWNER TO postgres;

--
-- Name: order_status_type; Type: TYPE; Schema: ecommerce; Owner: postgres
--

CREATE TYPE ecommerce.order_status_type AS ENUM (
    'pending',
    'confirmed',
    'processing',
    'shipped',
    'delivered',
    'cancelled',
    'refunded'
);


ALTER TYPE ecommerce.order_status_type OWNER TO postgres;

--
-- Name: positive_decimal; Type: DOMAIN; Schema: ecommerce; Owner: postgres
--

CREATE DOMAIN ecommerce.positive_decimal AS numeric(10,2)
	CONSTRAINT positive_decimal_check CHECK ((VALUE >= (0)::numeric));


ALTER DOMAIN ecommerce.positive_decimal OWNER TO postgres;

--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_updated_at_column() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: orders; Type: TABLE; Schema: ecommerce; Owner: postgres
--

CREATE TABLE ecommerce.orders (
    order_id uuid DEFAULT gen_random_uuid() NOT NULL,
    order_number character varying(50) NOT NULL,
    customer_id uuid NOT NULL,
    order_status character varying(50) DEFAULT 'pending'::character varying NOT NULL,
    payment_status character varying(50) DEFAULT 'unpaid'::character varying NOT NULL,
    subtotal numeric(10,2) NOT NULL,
    tax_amount numeric(10,2) DEFAULT 0,
    shipping_amount numeric(10,2) DEFAULT 0,
    total_amount numeric(10,2) NOT NULL,
    currency_code character(3) DEFAULT 'USD'::bpchar,
    notes text,
    ordered_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    shipped_at timestamp without time zone,
    delivered_at timestamp without time zone
);


ALTER TABLE ecommerce.orders OWNER TO postgres;

--
-- Name: TABLE orders; Type: COMMENT; Schema: ecommerce; Owner: postgres
--

COMMENT ON TABLE ecommerce.orders IS '注文情報';


--
-- Name: COLUMN orders.order_status; Type: COMMENT; Schema: ecommerce; Owner: postgres
--

COMMENT ON COLUMN ecommerce.orders.order_status IS '注文ステータス（pending, confirmed, processing, shipped, delivered, cancelled, refunded）';


--
-- Name: daily_sales_summary; Type: MATERIALIZED VIEW; Schema: analytics; Owner: postgres
--

CREATE MATERIALIZED VIEW analytics.daily_sales_summary AS
 SELECT date(o.ordered_at) AS order_date,
    count(DISTINCT o.order_id) AS order_count,
    count(DISTINCT o.customer_id) AS customer_count,
    sum(o.total_amount) AS total_revenue,
    avg(o.total_amount) AS avg_order_value
   FROM ecommerce.orders o
  WHERE ((o.order_status)::text <> 'cancelled'::text)
  GROUP BY (date(o.ordered_at))
  WITH NO DATA;


ALTER TABLE analytics.daily_sales_summary OWNER TO postgres;

--
-- Name: page_views; Type: TABLE; Schema: analytics; Owner: postgres
--

CREATE TABLE analytics.page_views (
    view_id bigint NOT NULL,
    session_id uuid NOT NULL,
    user_id uuid,
    page_url text NOT NULL,
    referrer_url text,
    user_agent text,
    ip_address inet,
    country_code character(2),
    viewed_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE analytics.page_views OWNER TO postgres;

--
-- Name: TABLE page_views; Type: COMMENT; Schema: analytics; Owner: postgres
--

COMMENT ON TABLE analytics.page_views IS 'ページビュー追跡データ';


--
-- Name: page_views_view_id_seq; Type: SEQUENCE; Schema: analytics; Owner: postgres
--

CREATE SEQUENCE analytics.page_views_view_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE analytics.page_views_view_id_seq OWNER TO postgres;

--
-- Name: page_views_view_id_seq; Type: SEQUENCE OWNED BY; Schema: analytics; Owner: postgres
--

ALTER SEQUENCE analytics.page_views_view_id_seq OWNED BY analytics.page_views.view_id;


--
-- Name: product_stats; Type: TABLE; Schema: analytics; Owner: postgres
--

CREATE TABLE analytics.product_stats (
    stat_id integer NOT NULL,
    product_id uuid NOT NULL,
    date date NOT NULL,
    view_count integer DEFAULT 0,
    add_to_cart_count integer DEFAULT 0,
    purchase_count integer DEFAULT 0,
    revenue numeric(10,2) DEFAULT 0
);


ALTER TABLE analytics.product_stats OWNER TO postgres;

--
-- Name: product_stats_stat_id_seq; Type: SEQUENCE; Schema: analytics; Owner: postgres
--

CREATE SEQUENCE analytics.product_stats_stat_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE analytics.product_stats_stat_id_seq OWNER TO postgres;

--
-- Name: product_stats_stat_id_seq; Type: SEQUENCE OWNED BY; Schema: analytics; Owner: postgres
--

ALTER SEQUENCE analytics.product_stats_stat_id_seq OWNED BY analytics.product_stats.stat_id;


--
-- Name: roles; Type: TABLE; Schema: auth; Owner: postgres
--

CREATE TABLE auth.roles (
    role_id integer NOT NULL,
    role_name character varying(50) NOT NULL,
    description text
);


ALTER TABLE auth.roles OWNER TO postgres;

--
-- Name: roles_role_id_seq; Type: SEQUENCE; Schema: auth; Owner: postgres
--

CREATE SEQUENCE auth.roles_role_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE auth.roles_role_id_seq OWNER TO postgres;

--
-- Name: roles_role_id_seq; Type: SEQUENCE OWNED BY; Schema: auth; Owner: postgres
--

ALTER SEQUENCE auth.roles_role_id_seq OWNED BY auth.roles.role_id;


--
-- Name: user_profiles; Type: TABLE; Schema: auth; Owner: postgres
--

CREATE TABLE auth.user_profiles (
    profile_id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    first_name character varying(100),
    last_name character varying(100),
    phone character varying(20),
    birth_date date,
    avatar_url text,
    bio text
);


ALTER TABLE auth.user_profiles OWNER TO postgres;

--
-- Name: user_roles; Type: TABLE; Schema: auth; Owner: postgres
--

CREATE TABLE auth.user_roles (
    user_id uuid NOT NULL,
    role_id integer NOT NULL,
    assigned_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE auth.user_roles OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: auth; Owner: postgres
--

CREATE TABLE auth.users (
    user_id uuid DEFAULT gen_random_uuid() NOT NULL,
    email character varying(255) NOT NULL,
    username character varying(100) NOT NULL,
    password_hash character varying(255) NOT NULL,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE auth.users OWNER TO postgres;

--
-- Name: TABLE users; Type: COMMENT; Schema: auth; Owner: postgres
--

COMMENT ON TABLE auth.users IS 'システムユーザー情報';


--
-- Name: products; Type: TABLE; Schema: ecommerce; Owner: postgres
--

CREATE TABLE ecommerce.products (
    product_id uuid DEFAULT gen_random_uuid() NOT NULL,
    sku character varying(100) NOT NULL,
    product_name character varying(255) NOT NULL,
    description text,
    price numeric(10,2) NOT NULL,
    cost numeric(10,2),
    stock_quantity integer DEFAULT 0,
    weight numeric(8,3),
    is_active boolean DEFAULT true,
    created_by uuid,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT products_cost_check CHECK ((cost >= (0)::numeric)),
    CONSTRAINT products_price_check CHECK ((price >= (0)::numeric)),
    CONSTRAINT products_stock_quantity_check CHECK ((stock_quantity >= 0))
);


ALTER TABLE ecommerce.products OWNER TO postgres;

--
-- Name: TABLE products; Type: COMMENT; Schema: ecommerce; Owner: postgres
--

COMMENT ON TABLE ecommerce.products IS '商品マスタ';


--
-- Name: COLUMN products.sku; Type: COMMENT; Schema: ecommerce; Owner: postgres
--

COMMENT ON COLUMN ecommerce.products.sku IS '在庫管理単位（Stock Keeping Unit）';


--
-- Name: reviews; Type: TABLE; Schema: ecommerce; Owner: postgres
--

CREATE TABLE ecommerce.reviews (
    review_id uuid DEFAULT gen_random_uuid() NOT NULL,
    product_id uuid NOT NULL,
    customer_id uuid NOT NULL,
    rating integer NOT NULL,
    title character varying(255),
    comment text,
    is_verified_purchase boolean DEFAULT false,
    helpful_count integer DEFAULT 0,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT reviews_rating_check CHECK (((rating >= 1) AND (rating <= 5)))
);


ALTER TABLE ecommerce.reviews OWNER TO postgres;

--
-- Name: active_products; Type: VIEW; Schema: ecommerce; Owner: postgres
--

CREATE VIEW ecommerce.active_products AS
 SELECT p.product_id,
    p.sku,
    p.product_name,
    p.price,
    p.stock_quantity,
    count(DISTINCT r.review_id) AS review_count,
    avg(r.rating) AS avg_rating
   FROM (ecommerce.products p
     LEFT JOIN ecommerce.reviews r ON ((p.product_id = r.product_id)))
  WHERE (p.is_active = true)
  GROUP BY p.product_id, p.sku, p.product_name, p.price, p.stock_quantity;


ALTER TABLE ecommerce.active_products OWNER TO postgres;

--
-- Name: addresses; Type: TABLE; Schema: ecommerce; Owner: postgres
--

CREATE TABLE ecommerce.addresses (
    address_id uuid DEFAULT gen_random_uuid() NOT NULL,
    entity_type character varying(50) NOT NULL,
    entity_id uuid NOT NULL,
    address_type character varying(20) NOT NULL,
    street_address_1 character varying(255) NOT NULL,
    street_address_2 character varying(255),
    city character varying(100) NOT NULL,
    state_province character varying(100),
    postal_code character varying(20),
    country_code character(2) NOT NULL,
    is_default boolean DEFAULT false
);


ALTER TABLE ecommerce.addresses OWNER TO postgres;

--
-- Name: categories; Type: TABLE; Schema: ecommerce; Owner: postgres
--

CREATE TABLE ecommerce.categories (
    category_id integer NOT NULL,
    parent_category_id integer,
    category_name character varying(100) NOT NULL,
    slug character varying(100) NOT NULL,
    description text,
    is_active boolean DEFAULT true,
    sort_order integer DEFAULT 0
);


ALTER TABLE ecommerce.categories OWNER TO postgres;

--
-- Name: categories_category_id_seq; Type: SEQUENCE; Schema: ecommerce; Owner: postgres
--

CREATE SEQUENCE ecommerce.categories_category_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE ecommerce.categories_category_id_seq OWNER TO postgres;

--
-- Name: categories_category_id_seq; Type: SEQUENCE OWNED BY; Schema: ecommerce; Owner: postgres
--

ALTER SEQUENCE ecommerce.categories_category_id_seq OWNED BY ecommerce.categories.category_id;


--
-- Name: customers; Type: TABLE; Schema: ecommerce; Owner: postgres
--

CREATE TABLE ecommerce.customers (
    customer_id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    customer_number character varying(50) NOT NULL,
    company_name character varying(255),
    tax_id character varying(50),
    credit_limit numeric(10,2) DEFAULT 0
);


ALTER TABLE ecommerce.customers OWNER TO postgres;

--
-- Name: order_items; Type: TABLE; Schema: ecommerce; Owner: postgres
--

CREATE TABLE ecommerce.order_items (
    order_item_id uuid DEFAULT gen_random_uuid() NOT NULL,
    order_id uuid NOT NULL,
    product_id uuid NOT NULL,
    quantity integer NOT NULL,
    unit_price numeric(10,2) NOT NULL,
    discount_amount numeric(10,2) DEFAULT 0,
    tax_amount numeric(10,2) DEFAULT 0,
    total_amount numeric(10,2) NOT NULL,
    CONSTRAINT order_items_quantity_check CHECK ((quantity > 0))
);


ALTER TABLE ecommerce.order_items OWNER TO postgres;

--
-- Name: product_categories; Type: TABLE; Schema: ecommerce; Owner: postgres
--

CREATE TABLE ecommerce.product_categories (
    product_id uuid NOT NULL,
    category_id integer NOT NULL,
    is_primary boolean DEFAULT false
);


ALTER TABLE ecommerce.product_categories OWNER TO postgres;

--
-- Name: product_images; Type: TABLE; Schema: ecommerce; Owner: postgres
--

CREATE TABLE ecommerce.product_images (
    image_id integer NOT NULL,
    product_id uuid NOT NULL,
    image_url text NOT NULL,
    alt_text character varying(255),
    is_primary boolean DEFAULT false,
    sort_order integer DEFAULT 0
);


ALTER TABLE ecommerce.product_images OWNER TO postgres;

--
-- Name: product_images_image_id_seq; Type: SEQUENCE; Schema: ecommerce; Owner: postgres
--

CREATE SEQUENCE ecommerce.product_images_image_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE ecommerce.product_images_image_id_seq OWNER TO postgres;

--
-- Name: product_images_image_id_seq; Type: SEQUENCE OWNED BY; Schema: ecommerce; Owner: postgres
--

ALTER SEQUENCE ecommerce.product_images_image_id_seq OWNED BY ecommerce.product_images.image_id;


--
-- Name: system_config; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.system_config (
    config_id integer NOT NULL,
    config_key character varying(255) NOT NULL,
    config_value text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.system_config OWNER TO postgres;

--
-- Name: system_config_config_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.system_config_config_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.system_config_config_id_seq OWNER TO postgres;

--
-- Name: system_config_config_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.system_config_config_id_seq OWNED BY public.system_config.config_id;


--
-- Name: page_views view_id; Type: DEFAULT; Schema: analytics; Owner: postgres
--

ALTER TABLE ONLY analytics.page_views ALTER COLUMN view_id SET DEFAULT nextval('analytics.page_views_view_id_seq'::regclass);


--
-- Name: product_stats stat_id; Type: DEFAULT; Schema: analytics; Owner: postgres
--

ALTER TABLE ONLY analytics.product_stats ALTER COLUMN stat_id SET DEFAULT nextval('analytics.product_stats_stat_id_seq'::regclass);


--
-- Name: roles role_id; Type: DEFAULT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.roles ALTER COLUMN role_id SET DEFAULT nextval('auth.roles_role_id_seq'::regclass);


--
-- Name: categories category_id; Type: DEFAULT; Schema: ecommerce; Owner: postgres
--

ALTER TABLE ONLY ecommerce.categories ALTER COLUMN category_id SET DEFAULT nextval('ecommerce.categories_category_id_seq'::regclass);


--
-- Name: product_images image_id; Type: DEFAULT; Schema: ecommerce; Owner: postgres
--

ALTER TABLE ONLY ecommerce.product_images ALTER COLUMN image_id SET DEFAULT nextval('ecommerce.product_images_image_id_seq'::regclass);


--
-- Name: system_config config_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.system_config ALTER COLUMN config_id SET DEFAULT nextval('public.system_config_config_id_seq'::regclass);


--
-- Name: page_views page_views_pkey; Type: CONSTRAINT; Schema: analytics; Owner: postgres
--

ALTER TABLE ONLY analytics.page_views
    ADD CONSTRAINT page_views_pkey PRIMARY KEY (view_id);


--
-- Name: product_stats product_stats_pkey; Type: CONSTRAINT; Schema: analytics; Owner: postgres
--

ALTER TABLE ONLY analytics.product_stats
    ADD CONSTRAINT product_stats_pkey PRIMARY KEY (stat_id);


--
-- Name: product_stats unique_product_date; Type: CONSTRAINT; Schema: analytics; Owner: postgres
--

ALTER TABLE ONLY analytics.product_stats
    ADD CONSTRAINT unique_product_date UNIQUE (product_id, date);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (role_id);


--
-- Name: roles roles_role_name_key; Type: CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.roles
    ADD CONSTRAINT roles_role_name_key UNIQUE (role_name);


--
-- Name: user_profiles user_profiles_pkey; Type: CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.user_profiles
    ADD CONSTRAINT user_profiles_pkey PRIMARY KEY (profile_id);


--
-- Name: user_profiles user_profiles_user_id_key; Type: CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.user_profiles
    ADD CONSTRAINT user_profiles_user_id_key UNIQUE (user_id);


--
-- Name: user_roles user_roles_pkey; Type: CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.user_roles
    ADD CONSTRAINT user_roles_pkey PRIMARY KEY (user_id, role_id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);


--
-- Name: users users_username_key; Type: CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- Name: addresses addresses_pkey; Type: CONSTRAINT; Schema: ecommerce; Owner: postgres
--

ALTER TABLE ONLY ecommerce.addresses
    ADD CONSTRAINT addresses_pkey PRIMARY KEY (address_id);


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: ecommerce; Owner: postgres
--

ALTER TABLE ONLY ecommerce.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (category_id);


--
-- Name: categories categories_slug_key; Type: CONSTRAINT; Schema: ecommerce; Owner: postgres
--

ALTER TABLE ONLY ecommerce.categories
    ADD CONSTRAINT categories_slug_key UNIQUE (slug);


--
-- Name: customers customers_customer_number_key; Type: CONSTRAINT; Schema: ecommerce; Owner: postgres
--

ALTER TABLE ONLY ecommerce.customers
    ADD CONSTRAINT customers_customer_number_key UNIQUE (customer_number);


--
-- Name: customers customers_pkey; Type: CONSTRAINT; Schema: ecommerce; Owner: postgres
--

ALTER TABLE ONLY ecommerce.customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (customer_id);


--
-- Name: customers customers_user_id_key; Type: CONSTRAINT; Schema: ecommerce; Owner: postgres
--

ALTER TABLE ONLY ecommerce.customers
    ADD CONSTRAINT customers_user_id_key UNIQUE (user_id);


--
-- Name: order_items order_items_pkey; Type: CONSTRAINT; Schema: ecommerce; Owner: postgres
--

ALTER TABLE ONLY ecommerce.order_items
    ADD CONSTRAINT order_items_pkey PRIMARY KEY (order_item_id);


--
-- Name: orders orders_order_number_key; Type: CONSTRAINT; Schema: ecommerce; Owner: postgres
--

ALTER TABLE ONLY ecommerce.orders
    ADD CONSTRAINT orders_order_number_key UNIQUE (order_number);


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: ecommerce; Owner: postgres
--

ALTER TABLE ONLY ecommerce.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (order_id);


--
-- Name: product_categories product_categories_pkey; Type: CONSTRAINT; Schema: ecommerce; Owner: postgres
--

ALTER TABLE ONLY ecommerce.product_categories
    ADD CONSTRAINT product_categories_pkey PRIMARY KEY (product_id, category_id);


--
-- Name: product_images product_images_pkey; Type: CONSTRAINT; Schema: ecommerce; Owner: postgres
--

ALTER TABLE ONLY ecommerce.product_images
    ADD CONSTRAINT product_images_pkey PRIMARY KEY (image_id);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: ecommerce; Owner: postgres
--

ALTER TABLE ONLY ecommerce.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (product_id);


--
-- Name: products products_sku_key; Type: CONSTRAINT; Schema: ecommerce; Owner: postgres
--

ALTER TABLE ONLY ecommerce.products
    ADD CONSTRAINT products_sku_key UNIQUE (sku);


--
-- Name: reviews reviews_pkey; Type: CONSTRAINT; Schema: ecommerce; Owner: postgres
--

ALTER TABLE ONLY ecommerce.reviews
    ADD CONSTRAINT reviews_pkey PRIMARY KEY (review_id);


--
-- Name: reviews unique_customer_product_review; Type: CONSTRAINT; Schema: ecommerce; Owner: postgres
--

ALTER TABLE ONLY ecommerce.reviews
    ADD CONSTRAINT unique_customer_product_review UNIQUE (product_id, customer_id);


--
-- Name: system_config system_config_config_key_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.system_config
    ADD CONSTRAINT system_config_config_key_key UNIQUE (config_key);


--
-- Name: system_config system_config_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.system_config
    ADD CONSTRAINT system_config_pkey PRIMARY KEY (config_id);


--
-- Name: idx_page_views_session; Type: INDEX; Schema: analytics; Owner: postgres
--

CREATE INDEX idx_page_views_session ON analytics.page_views USING btree (session_id);


--
-- Name: idx_page_views_viewed_at; Type: INDEX; Schema: analytics; Owner: postgres
--

CREATE INDEX idx_page_views_viewed_at ON analytics.page_views USING btree (viewed_at);


--
-- Name: idx_users_email; Type: INDEX; Schema: auth; Owner: postgres
--

CREATE INDEX idx_users_email ON auth.users USING btree (email);


--
-- Name: idx_users_username; Type: INDEX; Schema: auth; Owner: postgres
--

CREATE INDEX idx_users_username ON auth.users USING btree (username);


--
-- Name: idx_addresses_entity; Type: INDEX; Schema: ecommerce; Owner: postgres
--

CREATE INDEX idx_addresses_entity ON ecommerce.addresses USING btree (entity_type, entity_id);


--
-- Name: idx_orders_customer; Type: INDEX; Schema: ecommerce; Owner: postgres
--

CREATE INDEX idx_orders_customer ON ecommerce.orders USING btree (customer_id);


--
-- Name: idx_orders_ordered_at; Type: INDEX; Schema: ecommerce; Owner: postgres
--

CREATE INDEX idx_orders_ordered_at ON ecommerce.orders USING btree (ordered_at);


--
-- Name: idx_orders_status; Type: INDEX; Schema: ecommerce; Owner: postgres
--

CREATE INDEX idx_orders_status ON ecommerce.orders USING btree (order_status);


--
-- Name: idx_products_active; Type: INDEX; Schema: ecommerce; Owner: postgres
--

CREATE INDEX idx_products_active ON ecommerce.products USING btree (is_active) WHERE (is_active = true);


--
-- Name: idx_products_sku; Type: INDEX; Schema: ecommerce; Owner: postgres
--

CREATE INDEX idx_products_sku ON ecommerce.products USING btree (sku);


--
-- Name: users update_users_updated_at; Type: TRIGGER; Schema: auth; Owner: postgres
--

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON auth.users FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: products update_products_updated_at; Type: TRIGGER; Schema: ecommerce; Owner: postgres
--

CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON ecommerce.products FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: page_views fk_page_view_user; Type: FK CONSTRAINT; Schema: analytics; Owner: postgres
--

ALTER TABLE ONLY analytics.page_views
    ADD CONSTRAINT fk_page_view_user FOREIGN KEY (user_id) REFERENCES auth.users(user_id) ON DELETE SET NULL;


--
-- Name: product_stats fk_product_stats_product; Type: FK CONSTRAINT; Schema: analytics; Owner: postgres
--

ALTER TABLE ONLY analytics.product_stats
    ADD CONSTRAINT fk_product_stats_product FOREIGN KEY (product_id) REFERENCES ecommerce.products(product_id) ON DELETE CASCADE;


--
-- Name: user_profiles fk_profile_user; Type: FK CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.user_profiles
    ADD CONSTRAINT fk_profile_user FOREIGN KEY (user_id) REFERENCES auth.users(user_id) ON DELETE CASCADE;


--
-- Name: user_roles fk_user_roles_role; Type: FK CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.user_roles
    ADD CONSTRAINT fk_user_roles_role FOREIGN KEY (role_id) REFERENCES auth.roles(role_id) ON DELETE CASCADE;


--
-- Name: user_roles fk_user_roles_user; Type: FK CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.user_roles
    ADD CONSTRAINT fk_user_roles_user FOREIGN KEY (user_id) REFERENCES auth.users(user_id) ON DELETE CASCADE;


--
-- Name: categories fk_category_parent; Type: FK CONSTRAINT; Schema: ecommerce; Owner: postgres
--

ALTER TABLE ONLY ecommerce.categories
    ADD CONSTRAINT fk_category_parent FOREIGN KEY (parent_category_id) REFERENCES ecommerce.categories(category_id) ON DELETE CASCADE;


--
-- Name: customers fk_customer_user; Type: FK CONSTRAINT; Schema: ecommerce; Owner: postgres
--

ALTER TABLE ONLY ecommerce.customers
    ADD CONSTRAINT fk_customer_user FOREIGN KEY (user_id) REFERENCES auth.users(user_id) ON DELETE SET NULL;


--
-- Name: product_images fk_image_product; Type: FK CONSTRAINT; Schema: ecommerce; Owner: postgres
--

ALTER TABLE ONLY ecommerce.product_images
    ADD CONSTRAINT fk_image_product FOREIGN KEY (product_id) REFERENCES ecommerce.products(product_id) ON DELETE CASCADE;


--
-- Name: orders fk_order_customer; Type: FK CONSTRAINT; Schema: ecommerce; Owner: postgres
--

ALTER TABLE ONLY ecommerce.orders
    ADD CONSTRAINT fk_order_customer FOREIGN KEY (customer_id) REFERENCES ecommerce.customers(customer_id);


--
-- Name: order_items fk_order_item_order; Type: FK CONSTRAINT; Schema: ecommerce; Owner: postgres
--

ALTER TABLE ONLY ecommerce.order_items
    ADD CONSTRAINT fk_order_item_order FOREIGN KEY (order_id) REFERENCES ecommerce.orders(order_id) ON DELETE CASCADE;


--
-- Name: order_items fk_order_item_product; Type: FK CONSTRAINT; Schema: ecommerce; Owner: postgres
--

ALTER TABLE ONLY ecommerce.order_items
    ADD CONSTRAINT fk_order_item_product FOREIGN KEY (product_id) REFERENCES ecommerce.products(product_id);


--
-- Name: product_categories fk_prod_cat_category; Type: FK CONSTRAINT; Schema: ecommerce; Owner: postgres
--

ALTER TABLE ONLY ecommerce.product_categories
    ADD CONSTRAINT fk_prod_cat_category FOREIGN KEY (category_id) REFERENCES ecommerce.categories(category_id) ON DELETE CASCADE;


--
-- Name: product_categories fk_prod_cat_product; Type: FK CONSTRAINT; Schema: ecommerce; Owner: postgres
--

ALTER TABLE ONLY ecommerce.product_categories
    ADD CONSTRAINT fk_prod_cat_product FOREIGN KEY (product_id) REFERENCES ecommerce.products(product_id) ON DELETE CASCADE;


--
-- Name: products fk_product_creator; Type: FK CONSTRAINT; Schema: ecommerce; Owner: postgres
--

ALTER TABLE ONLY ecommerce.products
    ADD CONSTRAINT fk_product_creator FOREIGN KEY (created_by) REFERENCES auth.users(user_id) ON DELETE SET NULL;


--
-- Name: reviews fk_review_customer; Type: FK CONSTRAINT; Schema: ecommerce; Owner: postgres
--

ALTER TABLE ONLY ecommerce.reviews
    ADD CONSTRAINT fk_review_customer FOREIGN KEY (customer_id) REFERENCES ecommerce.customers(customer_id);


--
-- Name: reviews fk_review_product; Type: FK CONSTRAINT; Schema: ecommerce; Owner: postgres
--

ALTER TABLE ONLY ecommerce.reviews
    ADD CONSTRAINT fk_review_product FOREIGN KEY (product_id) REFERENCES ecommerce.products(product_id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

