-- The four customers and two pauses the retired Database class seeded at every start - now once per database.
INSERT INTO customer (name, meals_per_day, price_per_meal, meal_type) VALUES ('Ravi', 2, 120, 'VEG');
INSERT INTO customer (name, meals_per_day, price_per_meal, meal_type) VALUES ('Meera', 1, 150, 'NON_VEG');
INSERT INTO customer (name, meals_per_day, price_per_meal, meal_type) VALUES ('Sunil', 3, 100, 'VEG');
INSERT INTO customer (name, meals_per_day, price_per_meal, meal_type) VALUES ('Priya', 1, 120, 'VEGAN');
INSERT INTO pause (customer_id, days) SELECT id, 3 FROM customer WHERE name = 'Sunil';
INSERT INTO pause (customer_id, days) SELECT id, 2 FROM customer WHERE name = 'Priya';
