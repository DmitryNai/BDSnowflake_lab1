INSERT INTO fact_sale (
    sale_date_id,
    customer_id,
    seller_id,
    product_id,
    store_id,
    quantity,
    total_price
)

WITH src AS (
    SELECT
        TO_DATE(sale_date, 'MM/DD/YYYY') AS sale_dt,
        customer_email,
        seller_email,
        TRIM(product_brand) AS brand_name,
        product_name,
        store_name,
        NULLIF(sale_quantity, '')::INTEGER AS qty,
        NULLIF(sale_total_price, '')::NUMERIC(10,2) AS price
    FROM mock_data
    WHERE TRIM(COALESCE(sale_date, '')) <> ''
)

SELECT
    d.id,
    c.id,
    s.id,
    p.id,
    st.id,
    src.qty,
    src.price
FROM src

JOIN dim_date d
    ON d.full_date = src.sale_dt

JOIN dim_customer c
    ON c.email = src.customer_email

JOIN dim_seller s
    ON s.email = src.seller_email

JOIN dim_brand b
    ON b.brand_name = src.brand_name

JOIN dim_product p
    ON p.product_name = src.product_name
   AND p.brand_id = b.id

JOIN dim_store st
    ON st.store_name = src.store_name;