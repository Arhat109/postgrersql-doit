-- терминал 1:
\c hw4;
SET search_path TO public;

BEGIN;
UPDATE accounts SET amount = 1001.5 WHERE id = 1;

-- Ждем 5 секунд, чтобы дать время запустить вторую транзакцию
SELECT pg_sleep(30);

-- Пытаемся обновить вторую строку (заблокированную второй транзакцией)
UPDATE accounts SET amount = 2025 WHERE id = 2;

COMMIT;
