# ДЗ №2

### 1. входим в двух консолях (K1,K2 далее) в локальную тестовую БД (одинаково)
```
~> psql -h 127.0.0.1 -U postgres -W
Пароль: 
psql (15.10 (Debian 15.10-0+deb12u1))
SSL-соединение (протокол: TLSv1.3, шифр: TLS_AES_256_GCM_SHA384, сжатие: выкл.)
Введите "help", чтобы получить справку.

postgres=#
```

### 2. Подключение к тестовой БД (одинаково)
```
postgres=# \c thai
Пароль: 
SSL-соединение (протокол: TLSv1.3, шифр: TLS_AES_256_GCM_SHA384, сжатие: выкл.)
Вы подключены к базе данных "thai" как пользователь "postgres".
thai=# SET search_path=book;
SET
thai=#
```

### 3. Консоль К1:

#### 3.1. Текущий уровень изоляции:
```
thai=# SHOW transaction_isolation;
 transaction_isolation 
-----------------------
 read committed
(1 строка)

thai=#
```

#### 3.2. Консоль К1: создание таблицы и добавление записей:
```
thai=# CREATE TABLE IF NOT EXISTS test (id serial, name varchar(255) NOT NULL DEFAULT '');
CREATE TABLE
thai=# INSERT INTO test(name) VALUES ('vasya'),('petya'),('spb');
INSERT 0 3
thai=# INSERT INTO test(name) VALUES ('vasya2'),('petya2'),('spb2');
INSERT 0 3
thai=#
```

#### 3.3. Начало транзакции (и в консоли К2 тоже)
```
thai=# BEGIN;
thai*#
```

#### 3.4. Консоль К1:
```
thai=*# INSERT INTO test(name) VALUES ('Novosibirsk');
INSERT 0 1
thai=*#
```

#### 3.4. Консоль К2:
```
thai=*# SELECT * FROM test;
 id |  name  
----+--------
  1 | vasya
  2 | petya
  3 | spb
  4 | vasya2
  5 | petya2
  6 | spb2
(6 строк)

thai=*#
```

**Добавленная в К1 запись отсутствует в выборке в К2. Добавление в транзакции, которая ещё не завершена.**

#### 3.5. Подтверждаем транзакцию добавления записи в К1:
```
K1: 
thai=*# COMMIT;
COMMIT
thai=#

K2:
thai=*# SELECT * FROM test;
 id |    name     
----+-------------
  1 | vasya
  2 | petya
  3 | spb
  4 | vasya2
  5 | petya2
  6 | spb2
  7 | Novosibirsk
(7 строк)

thai=*#
```

**Новая запись видна в той же транзакции К2, сразу после commit в К1. Добавление записи произошло, уровень изоляции допускает чтение новых данных.**

#### 3.6. commit в К2 также видим новую запись.

#### 3.7. Изменяем уровень изоляции в обоих консолях, после начала новой транзакции
```
thai=# SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
ПРЕДУПРЕЖДЕНИЕ:  SET TRANSACTION может выполняться только внутри блоков транзакций
SET
thai=# begin;
BEGIN
thai=*# INSERT INTO test(name) VALUES ('Github');
INSERT 0 1
thai=*#
```

!Упс, уровень изоляции в К1 остался **не изменен**! К2:
```
thai=# begin;
BEGIN
thai=*# SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SET
thai=*# SELECT * FROM test;
 id |    name     
----+-------------
  1 | vasya
  2 | petya
  3 | spb
  4 | vasya2
  5 | petya2
  6 | spb2
  7 | Novosibirsk
(7 строк)

thai=*#
```
**новой записи снова нет, т.к. нет commit в К1**

```
K1:
thai=*# COMMIT;
COMMIT
thai=#

K2:
thai=*# SELECT * FROM test;
 id |    name     
----+-------------
  1 | vasya
  2 | petya
  3 | spb
  4 | vasya2
  5 | petya2
  6 | spb2
  7 | Novosibirsk
(7 строк)

thai=*#
```
**В отличии от предыдущего, новой записи все равно нет, т.к. repeatable read не позволил получить новую запись в не завершенной транзакции**

Вывод: менять уровень изоляции на repeatable read правильно там, где требуется консистентность чтения, а не там где добавляются данные.
Проверка:

```
K1:
thai=# BEGIN;
BEGIN
thai=*# SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SET
thai=*# SHOW transaction_isolation;
 transaction_isolation 
-----------------------
 repeatable read
(1 строка)

thai=*# INSERT INTO test(name) VALUES ('Github2');
INSERT 0 1
thai=*#

K2:
thai=# SHOW transaction_isolation;
 transaction_isolation 
-----------------------
 read committed
(1 строка)

thai=# begin;
BEGIN
thai=*#

К2 начата транзакция до завершения вставки в К1, далее commit в К1 фиксирует новую запись, при этом в К2 видим:
thai=*# SELECT * FROM test;
 id |    name     
----+-------------
  1 | vasya
  2 | petya
  3 | spb
  4 | vasya2
  5 | petya2
  6 | spb2
  7 | Novosibirsk
  8 | Github
  9 | Github2
(9 строк)

thai=*# 
```

**Вывод: изменение уровня изоляции в К1 (вставка) не повлияло на выборку в К2**

