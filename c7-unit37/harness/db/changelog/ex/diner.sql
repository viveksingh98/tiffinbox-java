--liquibase formatted sql

--changeset diner:1
CREATE TABLE diner (id INT PRIMARY KEY, name VARCHAR(40) NOT NULL);
--rollback DROP TABLE diner;

--changeset diner:2
INSERT INTO diner (id, name) VALUES (1, 'Asha'), (2, 'Kiran'), (3, 'Neel');
--rollback DELETE FROM diner;
