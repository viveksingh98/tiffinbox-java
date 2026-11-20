-- Unit 18's harness: the same menu in three PostgreSQL tables, the allergen as text on each item's row (the labelled variant). The
-- rows are the INSERTs probe.u18.H18 prints from the shipped MenuDay.forDays(30) (sql3).
DROP SCHEMA IF EXISTS f3 CASCADE;
CREATE SCHEMA f3;
CREATE TABLE f3.menu (id text PRIMARY KEY);
CREATE TABLE f3.menu_item (id integer PRIMARY KEY, menu_id text NOT NULL REFERENCES f3.menu (id), meal_type text NOT NULL, name text NOT NULL, price integer NOT NULL);
CREATE TABLE f3.item_allergen (item_id integer NOT NULL REFERENCES f3.menu_item (id), allergen text NOT NULL, PRIMARY KEY (item_id, allergen));
