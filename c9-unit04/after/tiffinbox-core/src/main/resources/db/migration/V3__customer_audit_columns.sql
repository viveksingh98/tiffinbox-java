-- When a customer was added and last changed (Course 7, unit 38: Spring Data's auditing fills both); the four seeded rows keep NULL - nothing back-fills them.
ALTER TABLE customer ADD COLUMN created_at TIMESTAMP(6) WITH TIME ZONE;
ALTER TABLE customer ADD COLUMN updated_at TIMESTAMP(6) WITH TIME ZONE;
