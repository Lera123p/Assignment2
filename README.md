# Assignment2

Початковий неоптимізований код, який містить велику навантаженість умов в одному select, що призводить до поганої читабельності(багато join, які фільтрується вже після об’єднання (categories, orders).Також всі таблиці проходяться повністю (Full Table Scan) і Відсутні індекси.

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


Перший крок оптимізації – винесення фільтрів у CTE, де orders та products фільтруються за категоріями раніше.

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

Другий крок оптимізації, де в CTE виносить обчислення агрегатної функції SUM

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

Використання індексів, де відбувається швидше пошук по order_date, product_id, category_name

CREATE INDEX idx_order_date ON orders(order_date);

CREATE INDEX idx_ordered_products ON ordered_products(order_id);

CREATE INDEX idx_ordered_product_id ON ordered_products(product_id);

CREATE INDEX idx_products_category_id ON products(category_id);

CREATE INDEX idx_categories_name ON categories(category_name);

Використання USE INDEX, FORCE INDEX, STRAIGHT_JOIN

SELECT * FROM categories USE INDEX (idx_categories_name) WHERE category_name = 'Books';
Віддає перевагу індексу idx_categories_name при фільтрації.

SELECT * FROM ordered_products FORCE INDEX (idx_ordered_product_id) WHERE product_id = 10;
Змушує MySQL використовувати вказаний індекс idx_ordered_product_id .

SELECT * FROM categories c STRAIGHT_JOIN products p ON p.category_id = c.category_id WHERE c.category_name = 'Books';
Фіксація порядку, спочатку categories, а тільки потім products.
