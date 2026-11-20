-- Unit 18's harness: the menu in four PostgreSQL tables (the harness's own container, 20576 - never the unit's database). The rows
-- are the INSERTs probe.u18.H18 prints from the shipped MenuDay.forDays(30) (sql4): the same thirty menus TiffinBox's start inserts.
DROP SCHEMA IF EXISTS f4 CASCADE;
CREATE SCHEMA f4;
CREATE TABLE f4.menu (id text PRIMARY KEY);
CREATE TABLE f4.menu_item (id integer PRIMARY KEY, menu_id text NOT NULL REFERENCES f4.menu (id), meal_type text NOT NULL, name text NOT NULL, price integer NOT NULL);
CREATE TABLE f4.allergen (id integer PRIMARY KEY, name text NOT NULL UNIQUE);
CREATE TABLE f4.item_allergen (item_id integer NOT NULL REFERENCES f4.menu_item (id), allergen_id integer NOT NULL REFERENCES f4.allergen (id), PRIMARY KEY (item_id, allergen_id));
