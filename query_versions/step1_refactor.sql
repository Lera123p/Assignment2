--перший крок оптимізації--
WITH rechanged_orders AS (
  SELECT * FROM orders
  WHERE order_date >= '2024-01-01'
),
rechanged_products AS (
  SELECT p.* FROM products p
  JOIN categories c ON p.category_id = c.category_id
  WHERE c.category_name = 'Books'
)
SELECT c.name, c.email, SUM(op.quantity * op.price) AS total_spent
FROM customers c
JOIN rechanged_orders o ON c.customer_id = o.customer_id
JOIN ordered_products op ON o.order_id = op.order_id
JOIN rechanged_products p ON op.product_id = p.product_id
GROUP BY c.customer_id
HAVING total_spent > 5000 
ORDER BY total_spent;
