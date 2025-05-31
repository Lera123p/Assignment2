CREATE INDEX idx_order_date ON orders(order_date);

CREATE INDEX idx_ordered_products ON ordered_products(order_id);

CREATE INDEX idx_ordered_product_id ON ordered_products(product_id);

CREATE INDEX idx_products_category_id ON products(category_id);

CREATE INDEX idx_categories_name ON categories(category_name);
