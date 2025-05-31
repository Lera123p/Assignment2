WITH rechanged_orders AS (
  SELECT * FROM orders WHERE order_date >= '2024-01-01'
),
rechanged_products AS (
  SELECT p.product_id FROM products p
  JOIN categories c ON p.category_id = c.category_id
  WHERE c.category_name = 'Books'
),
customer_wasting AS (
  SELECT o.customer_id, SUM(op.quantity * op.price) AS total_spent
  FROM rechanged_orders o
  JOIN ordered_products op ON o.order_id = op.order_id
  WHERE op.product_id IN (SELECT product_id FROM rechanged_products)
  GROUP BY o.customer_id
)
SELECT c.name, c.email, cw.total_spent
FROM customer_wasting cw
JOIN customers c ON c.customer_id = cw.customer_id
WHERE cw.total_spent > 500
ORDER BY cw.total_spent;
