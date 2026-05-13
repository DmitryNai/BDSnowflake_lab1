CREATE TABLE IF NOT EXISTS dim_location (
    id           SERIAL PRIMARY KEY,
    country      VARCHAR(100) NOT NULL DEFAULT '',
    city         VARCHAR(100) NOT NULL DEFAULT '',
    state        VARCHAR(100) NOT NULL DEFAULT '',
    postal_code  VARCHAR(50)  NOT NULL DEFAULT '',
    CONSTRAINT uq_dim_location UNIQUE (country, city, state, postal_code)
);


CREATE TABLE IF NOT EXISTS dim_pet_category (
    id            SERIAL PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL,
    CONSTRAINT uq_dim_pet_category UNIQUE (category_name)
);


CREATE TABLE IF NOT EXISTS dim_product_category (
    id            SERIAL PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL,
    CONSTRAINT uq_dim_product_category UNIQUE (category_name)
);


CREATE TABLE IF NOT EXISTS dim_brand (
    id         SERIAL PRIMARY KEY,
    brand_name VARCHAR(200) NOT NULL,
    CONSTRAINT uq_dim_brand UNIQUE (brand_name)
);


CREATE TABLE IF NOT EXISTS dim_supplier (
    id            SERIAL PRIMARY KEY,
    supplier_name VARCHAR(200) NOT NULL,
    contact       VARCHAR(200),
    email         VARCHAR(200),
    phone         VARCHAR(50),
    address       VARCHAR(200),
    location_id   INTEGER NOT NULL REFERENCES dim_location(id),
    CONSTRAINT uq_dim_supplier UNIQUE (supplier_name)
);


CREATE TABLE IF NOT EXISTS dim_customer (
    id              SERIAL PRIMARY KEY,
    first_name      VARCHAR(100),
    last_name       VARCHAR(100),
    age             INTEGER,
    email           VARCHAR(200) NOT NULL,
    pet_name        VARCHAR(100),
    pet_type        VARCHAR(50),
    pet_breed       VARCHAR(100),
    location_id     INTEGER NOT NULL REFERENCES dim_location(id),
    CONSTRAINT uq_dim_customer_email UNIQUE (email)
);

CREATE TABLE IF NOT EXISTS dim_seller (
    id          SERIAL PRIMARY KEY,
    first_name  VARCHAR(100),
    last_name   VARCHAR(100),
    email       VARCHAR(200) NOT NULL,
    location_id INTEGER NOT NULL REFERENCES dim_location(id),
    CONSTRAINT uq_dim_seller_email UNIQUE (email)
);

CREATE TABLE IF NOT EXISTS dim_store (
    id             SERIAL PRIMARY KEY,
    store_name     VARCHAR(200) NOT NULL,
    store_location VARCHAR(200),
    phone          VARCHAR(50),
    email          VARCHAR(200),
    location_id    INTEGER NOT NULL REFERENCES dim_location(id),
    CONSTRAINT uq_dim_store UNIQUE (store_name)
);


CREATE TABLE IF NOT EXISTS dim_product (
    id                  SERIAL PRIMARY KEY,
    product_name        VARCHAR(200) NOT NULL,
    price               NUMERIC(10,2),
    weight              NUMERIC(10,2),
    color               VARCHAR(100),
    size                VARCHAR(50),
    material            VARCHAR(100),
    description         TEXT,
    rating              NUMERIC(3,1),
    reviews             INTEGER,
    release_date        DATE,
    expiry_date         DATE,
    product_category_id INTEGER NOT NULL REFERENCES dim_product_category(id),
    pet_category_id     INTEGER NOT NULL REFERENCES dim_pet_category(id),
    brand_id            INTEGER NOT NULL REFERENCES dim_brand(id),
    supplier_id         INTEGER NOT NULL REFERENCES dim_supplier(id),
    CONSTRAINT uq_dim_product UNIQUE (product_name, brand_id)
);

CREATE TABLE IF NOT EXISTS dim_date (
    id          SERIAL PRIMARY KEY,
    full_date   DATE     NOT NULL,
    day         SMALLINT NOT NULL,
    month       SMALLINT NOT NULL,
    year        SMALLINT NOT NULL,
    quarter     SMALLINT NOT NULL,
    day_of_week SMALLINT NOT NULL,
    CONSTRAINT uq_dim_date UNIQUE (full_date)
);


CREATE TABLE IF NOT EXISTS fact_sale (
    id           SERIAL PRIMARY KEY,
    sale_date_id  INTEGER NOT NULL REFERENCES dim_date(id),
    customer_id   INTEGER NOT NULL REFERENCES dim_customer(id),
    seller_id     INTEGER NOT NULL REFERENCES dim_seller(id),
    store_id      INTEGER NOT NULL REFERENCES dim_store(id),
    product_id    INTEGER NOT NULL REFERENCES dim_product(id),
    quantity      INTEGER NOT NULL,
    total_price   NUMERIC(12,2) NOT NULL
);

CREATE INDEX idx_fact_sales_date     ON fact_sale(sale_date_id);
CREATE INDEX idx_fact_sales_customer ON fact_sale(customer_id);
CREATE INDEX idx_fact_sales_seller   ON fact_sale(seller_id);
CREATE INDEX idx_fact_sales_product  ON fact_sale(product_id);
CREATE INDEX idx_fact_sales_store    ON fact_sale(store_id);