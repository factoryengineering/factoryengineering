---
description: Guidelines for writing PostgreSQL queries and schema design. Use when creating tables, writing queries, or tuning performance in PostgreSQL.
---

## Set-based operations over row-by-row

Express logic as single SQL statements rather than cursors or application-side loops. Use CTEs and window functions to keep complex queries readable:

```sql
-- ✅ Preferred: CTE with window function
WITH ranked_orders AS (
    SELECT customer_id, total,
           ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY total DESC) AS rn
    FROM orders
)
SELECT customer_id, total
FROM ranked_orders
WHERE rn = 1;

-- ❌ Avoid: fetching all rows and filtering in application code
SELECT customer_id, total FROM orders;
-- then loop in C# to find the max per customer
```

## Index and constrain early

Define constraints (`NOT NULL`, `UNIQUE`, `CHECK`, foreign keys) at table creation time. Add indexes for columns that appear in `WHERE`, `JOIN`, or `ORDER BY` clauses. Run `EXPLAIN ANALYZE` to verify the query plan uses them.
