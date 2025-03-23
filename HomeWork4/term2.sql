-- терминал 2:
\c hw4;
SET search_path TO public;

BEGIN;
UPDATE accounts SET amount=2222 WHERE id = 2;

UPDATE accounts SET amount=1111 WHERE id = 1;

COMMIT;
