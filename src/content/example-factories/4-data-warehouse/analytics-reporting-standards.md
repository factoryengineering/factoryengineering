---
description: Guidelines for designing star/snowflake schemas and reporting views. Use when creating fact tables, dimension tables, or materialized reporting views.
---

## Star schema with consistent grain

Every fact table must have a clearly documented grain — one row represents one measurable event. Dimension tables hold descriptive attributes and are joined by surrogate keys:

```sql
-- ✅ Preferred: clear grain and surrogate keys
CREATE TABLE fact_order_line (
    order_line_key BIGINT PRIMARY KEY,
    order_key      BIGINT REFERENCES dim_order(order_key),
    product_key    BIGINT REFERENCES dim_product(product_key),
    date_key       INT    REFERENCES dim_date(date_key),
    quantity       INT    NOT NULL,
    line_total     NUMERIC(12,2) NOT NULL
);

-- ❌ Avoid: mixed grain — order-level and line-level in the same table
CREATE TABLE fact_orders (
    order_id       BIGINT,
    line_item_id   BIGINT,  -- sometimes NULL for order-level rows
    order_total    NUMERIC(12,2),
    line_total     NUMERIC(12,2)
);
```

## Document definitions and refresh cadence

Every reporting view or materialized table must document what it measures, its grain, and how often it refreshes. If a downstream dashboard depends on it, note the SLA.
