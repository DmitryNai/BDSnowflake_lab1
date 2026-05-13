INSERT INTO dim_location (country, city, state, postal_code)
WITH loc AS (
    SELECT
        COALESCE(NULLIF(TRIM(customer_country), ''), '') AS country,
        '' AS city,
        '' AS state,
        COALESCE(NULLIF(TRIM(customer_postal_code), ''), '') AS postal_code
    FROM mock_data

    UNION

    SELECT
        COALESCE(NULLIF(TRIM(seller_country), ''), ''),
        '',
        '',
        COALESCE(NULLIF(TRIM(seller_postal_code), ''), '')
    FROM mock_data

    UNION

    SELECT
        COALESCE(NULLIF(TRIM(store_country), ''), ''),
        COALESCE(NULLIF(TRIM(store_city), ''), ''),
        COALESCE(NULLIF(TRIM(store_state), ''), ''),
        ''
    FROM mock_data

    UNION

    SELECT
        COALESCE(NULLIF(TRIM(supplier_country), ''), ''),
        COALESCE(NULLIF(TRIM(supplier_city), ''), ''),
        '',
        ''
    FROM mock_data
)
SELECT DISTINCT *
FROM loc
WHERE country <> ''
ON CONFLICT (country, city, state, postal_code) DO NOTHING;



INSERT INTO dim_pet_category (category_name)
SELECT DISTINCT TRIM(pet_category)
FROM mock_data
WHERE TRIM(COALESCE(pet_category, '')) <> ''
ON CONFLICT (category_name) DO NOTHING;



INSERT INTO dim_product_category (category_name)
SELECT DISTINCT TRIM(product_category)
FROM mock_data
WHERE TRIM(COALESCE(product_category, '')) <> ''
ON CONFLICT (category_name) DO NOTHING;



INSERT INTO dim_brand (brand_name)
SELECT DISTINCT TRIM(product_brand)
FROM mock_data
WHERE TRIM(COALESCE(product_brand, '')) <> ''
ON CONFLICT (brand_name) DO NOTHING;



INSERT INTO dim_customer (
    first_name,
    last_name,
    age,
    email,
    pet_name,
    pet_type,
    pet_breed,
    location_id
)
SELECT DISTINCT ON (m.customer_email)
    m.customer_first_name,
    m.customer_last_name,
    NULLIF(m.customer_age, '')::INTEGER,
    m.customer_email,
    m.customer_pet_name,
    m.customer_pet_type,
    m.customer_pet_breed,
    l.id
FROM mock_data m
JOIN dim_location l
    ON l.country = COALESCE(NULLIF(TRIM(m.customer_country), ''), '')
   AND l.city = ''
   AND l.state = ''
   AND l.postal_code = COALESCE(NULLIF(TRIM(m.customer_postal_code), ''), '')
WHERE TRIM(COALESCE(m.customer_email, '')) <> ''
ON CONFLICT (email) DO NOTHING;



INSERT INTO dim_seller (
    first_name,
    last_name,
    email,
    location_id
)
SELECT DISTINCT ON (m.seller_email)
    m.seller_first_name,
    m.seller_last_name,
    m.seller_email,
    l.id
FROM mock_data m
JOIN dim_location l
    ON l.country = COALESCE(NULLIF(TRIM(m.seller_country), ''), '')
   AND l.city = ''
   AND l.state = ''
   AND l.postal_code = COALESCE(NULLIF(TRIM(m.seller_postal_code), ''), '')
WHERE TRIM(COALESCE(m.seller_email, '')) <> ''
ON CONFLICT (email) DO NOTHING;



INSERT INTO dim_supplier (
    supplier_name,
    contact,
    email,
    phone,
    address,
    location_id
)
SELECT DISTINCT ON (m.supplier_name)
    m.supplier_name,
    m.supplier_contact,
    m.supplier_email,
    m.supplier_phone,
    m.supplier_address,
    l.id
FROM mock_data m
JOIN dim_location l
    ON l.country = COALESCE(NULLIF(TRIM(m.supplier_country), ''), '')
   AND l.city = COALESCE(NULLIF(TRIM(m.supplier_city), ''), '')
   AND l.state = ''
   AND l.postal_code = ''
WHERE TRIM(COALESCE(m.supplier_name, '')) <> ''
ON CONFLICT (supplier_name) DO NOTHING;



INSERT INTO dim_product (
    product_name,
    price,
    weight,
    color,
    size,
    material,
    description,
    rating,
    reviews,
    release_date,
    expiry_date,
    product_category_id,
    pet_category_id,
    brand_id,
    supplier_id
)
SELECT DISTINCT ON (m.product_name, m.product_brand)
    m.product_name,
    NULLIF(m.product_price, '')::NUMERIC(10,2),
    NULLIF(m.product_weight, '')::NUMERIC(10,2),
    m.product_color,
    m.product_size,
    m.product_material,
    m.product_description,
    NULLIF(m.product_rating, '')::NUMERIC(3,1),
    NULLIF(m.product_reviews, '')::INTEGER,

    CASE
        WHEN NULLIF(m.product_release_date, '') IS NOT NULL
        THEN TO_DATE(m.product_release_date, 'MM/DD/YYYY')
    END,

    CASE
        WHEN NULLIF(m.product_expiry_date, '') IS NOT NULL
        THEN TO_DATE(m.product_expiry_date, 'MM/DD/YYYY')
    END,

    pc.id,
    pt.id,
    b.id,
    s.id
FROM mock_data m
JOIN dim_product_category pc
    ON pc.category_name = TRIM(m.product_category)
JOIN dim_pet_category pt
    ON pt.category_name = TRIM(m.pet_category)
JOIN dim_brand b
    ON b.brand_name = TRIM(m.product_brand)
JOIN dim_supplier s
    ON s.supplier_name = m.supplier_name
WHERE TRIM(COALESCE(m.product_name, '')) <> ''
ON CONFLICT (product_name, brand_id) DO NOTHING;



INSERT INTO dim_store (
    store_name,
    store_location,
    phone,
    email,
    location_id
)
SELECT DISTINCT ON (m.store_name)
    m.store_name,
    m.store_location,
    m.store_phone,
    m.store_email,
    l.id
FROM mock_data m
JOIN dim_location l
    ON l.country = COALESCE(NULLIF(TRIM(m.store_country), ''), '')
   AND l.city = COALESCE(NULLIF(TRIM(m.store_city), ''), '')
   AND l.state = COALESCE(NULLIF(TRIM(m.store_state), ''), '')
   AND l.postal_code = ''
WHERE TRIM(COALESCE(m.store_name, '')) <> ''
ON CONFLICT (store_name) DO NOTHING;



INSERT INTO dim_date (
    full_date,
    day,
    month,
    year,
    quarter,
    day_of_week
)
SELECT DISTINCT
    d,
    EXTRACT(DAY FROM d)::SMALLINT,
    EXTRACT(MONTH FROM d)::SMALLINT,
    EXTRACT(YEAR FROM d)::SMALLINT,
    EXTRACT(QUARTER FROM d)::SMALLINT,
    EXTRACT(DOW FROM d)::SMALLINT
FROM (
    SELECT TO_DATE(sale_date, 'MM/DD/YYYY') AS d
    FROM mock_data
    WHERE TRIM(COALESCE(sale_date, '')) <> ''
) t
ON CONFLICT (full_date) DO NOTHING;