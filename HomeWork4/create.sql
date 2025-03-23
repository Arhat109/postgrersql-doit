-- drop old version:
DROP DATABASE hw4 WITH(FORCE);
DROP USER IF EXISTS hw4;

-- create new version:
CREATE USER hw4 WITH ENCRYPTED PASSWORD '123';
ALTER ROLE hw4 CREATEDB;

CREATE DATABASE hw4 WITH OWNER = hw4 ENCODING = 'UTF8';
GRANT ALL ON DATABASE hw4 TO postgres;
GRANT ALL ON DATABASE hw4 TO public;
\connect hw4;
SET search_path TO public;

-- 1. создаем таблицу:
CREATE TABLE accounts (id integer, amount numeric);

-- и вставляем 2 строки:
INSERT INTO accounts (id,amount) VALUES (1, 1000), (2, 2000);
