SELECT c.name, c.email, SUM(op.quantity * op.price) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN ordered_products op ON o.order_id = op.order_id
JOIN products p ON op.product_id = p.product_id
JOIN categories cat ON p.category_id = cat.category_id
WHERE cat.category_name = 'Books'
AND o.order_date >= '2024-01-01'
GROUP BY c.customer_id
HAVING total_spent > 5000
ORDER BY total_spent;
