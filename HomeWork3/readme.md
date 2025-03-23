-- drop old version:
DROP DATABASE hw3 WITH(FORCE);
DROP USER IF EXISTS hw3;

-- create new version:
CREATE USER hw3 WITH ENCRYPTED PASSWORD '123';
ALTER ROLE hw3 CREATEDB;

CREATE DATABASE hw3 WITH OWNER = hw3 ENCODING = 'UTF8';
GRANT ALL ON DATABASE hw3 TO postgres;
GRANT ALL ON DATABASE hw3 TO public;
\connect hw3;
SET search_path TO public;

-- 1. создаем таблицу:
CREATE TABLE texts (id serial, data varchar(64));

-- и вставляем 1млн случайных строк через генерацию МД5:
INSERT INTO texts (data) SELECT md5(random()::text) FROM generate_series(1, 1000000);

-- 2. смотрим размер файла таблицы через встроенное представление:
SELECT pg_size_pretty(pg_relation_size('texts')) AS size;

-- 3. обновляем строки таблицы 3 раза:
DO $$
DECLARE
    i INT := 0;
    num_iterations INT := 3;
BEGIN
    FOR i IN 1..num_iterations LOOP
        UPDATE texts
        SET data = data || chr(floor(random() * 62 + 48)::int);
    END LOOP;
END $$;

-- 4 и 5-е обновления делаем запросом с
WITH RECURSIVE add_char AS (
    SELECT 1 AS iteration
    UNION ALL
    SELECT iteration + 1
    FROM add_char
    WHERE iteration < 3
)
UPDATE texts
SET data = data || chr(floor(random() * 62 + 48)::int)
FROM add_char;

-- 3a размер файла таблицы:
SELECT pg_size_pretty(pg_relation_size('texts')) AS size;

-- 4. кол-во мертвых строчек и автовакуум последний раз:
SELECT
    relname AS table_name, 
    n_live_tup AS live_tuples,
    n_dead_tup AS dead_tuples,
    last_autovacuum, 
    last_autoanalyze
FROM 
    pg_stat_user_tables
WHERE 
    schemaname = 'public' AND relname = 'texts';

-- 6. 5 раз обновляем все строчки добавлением символа
-- Перенесено раньше, иначе автовакуум не приходит!
WITH RECURSIVE add_char AS (
    SELECT 1 AS iteration
    UNION ALL
    SELECT iteration + 1
    FROM add_char
    WHERE iteration < 6
)
UPDATE texts SET data = data || 'Y' FROM add_char;

-- 6a размер файла таблицы:
SELECT pg_size_pretty(pg_relation_size('texts')) AS size;

-- 5. ждем прихода автовакуума:
-- DO $$
-- DECLARE
--     lastStart TIMESTAMP;
-- BEGIN
--     LOOP
--         PERFORM pg_sleep(5);
-- 
--         SELECT last_autovacuum INTO lastStart FROM pg_stat_user_tables WHERE relname = 'texts';
--         RAISE NOTICE 'last=%', lastStart;
-- 
--         EXIT WHEN lastStart IS NOT NULL;
--     END LOOP;
-- END $$;
-- ==========================================================
-- !!! Не дождался, когда он соизволит придти !!! Руками:
VACUUM texts;

-- 7. размер файла таблицы:
SELECT pg_size_pretty(pg_relation_size('texts')) AS size;

-- 8. отключение автовакуума на этой табличке:
ALTER TABLE texts SET (autovacuum_enabled = false);

-- 9. обновить строчки 10 раз добавлением символа:
WITH RECURSIVE add_char AS (
    SELECT 1 AS iteration
    UNION ALL
    SELECT iteration + 1
    FROM add_char
    WHERE iteration < 11
)
UPDATE texts SET data = data || 'Y' FROM add_char;

-- 10. размер файла таблицы:
SELECT pg_size_pretty(pg_relation_size('texts')) AS size;

ALTER TABLE texts SET (autovacuum_enabled = true);

-- ========================================================================
-- выполнение скрипта:
-- ========================================================================
-- ~$ psql -h 127.0.0.1 -U postgres -W -f readme.md
-- Пароль: 
-- DROP DATABASE
-- DROP ROLE
-- CREATE ROLE
-- ALTER ROLE
-- CREATE DATABASE
-- GRANT
-- GRANT
-- Пароль: 
-- SSL-соединение (протокол: TLSv1.3, шифр: TLS_AES_256_GCM_SHA384, сжатие: выкл.)
-- Вы подключены к базе данных "hw3" как пользователь "postgres".
-- SET
-- CREATE TABLE
-- INSERT 0 1000000
-- =============== первый размер таблицы после вставки миллиона строк:
--  size   
-- -------
--  65 MB
-- (1 строка)
-- 
-- DO
-- UPDATE 1000000
-- =============== размер таблицы после обновления миллиона строк 5 раз:
--   size  
-- --------
--  333 MB
-- (1 строка)
-- 
--  table_name | live_tuples | dead_tuples | last_autovacuum | last_autoanalyze 
-- ------------+-------------+-------------+-----------------+------------------
--  texts      |     1000000 |     4000000 |                 | 
-- (1 строка)
-- 
-- UPDATE 1000000
-- =============== размер таблицы после повторного обновления миллиона строк 5 раз:
--   size  
-- --------
--  406 MB
-- (1 строка)
-- 
-- VACUUM
-- =============== размер таблицы НЕ ИЗМЕНИЛСЯ даже после принудительного автовакуум:
--   size  
-- --------
--  406 MB
-- (1 строка)
-- 
-- ALTER TABLE -- отключили автовакуум тут
-- UPDATE 1000000
-- =============== размер таблицы после обновления миллиона строк 10 раз:
--   size  
-- --------
--  406 MB
-- (1 строка)
-- 
-- ALTER TABLE -- включение автовакуума.

-- вывод? Автовакуум не работает. :)
