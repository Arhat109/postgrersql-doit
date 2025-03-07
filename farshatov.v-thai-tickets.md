# Домашнее задание №1

## Установить postgresql куда-нибудь (виртуалка).
Уже стоит 15 постгрес, разработка архитектуры БД для нашего направления
GEO-Service. Пропущено, и так уже раза 4 переустанавливался.. )

## Скачать БД по перевозкам.
Места мало, взял меньший вариант, командами с гитхаба, залито.
* Корректировка набора команд:
```
~>wget https://storage.googleapis.com/thaibus/thai_small.tar.gz && tar -xf thai_small.tar.gz && psql -h 127.0.0.1 -U postgres -W < thai.sql
```

## Подключение к БД:
~>psql -h 127.0.0.1 -U postgres -W

## Дальнейшие действия:
`postgres=# \l`
* вывод (лишнее удалил):
```
                                                    Список баз данных
    Имя     |  Владелец  | Кодировка | LC_COLLATE  |  LC_CTYPE   | локаль ICU | Провайдер локали |       Права доступа       
------------+------------+-----------+-------------+-------------+------------+------------------+---------------------------
 postgres   | postgres   | UTF8      | ru_RU.UTF-8 | ru_RU.UTF-8 |            | libc             | 
 template0  | postgres   | UTF8      | ru_RU.UTF-8 | ru_RU.UTF-8 |            | libc             | =c/postgres              +
            |            |           |             |             |            |                  | postgres=CTc/postgres
 template1  | postgres   | UTF8      | ru_RU.UTF-8 | ru_RU.UTF-8 |            | libc             | =c/postgres              +
            |            |           |             |             |            |                  | postgres=CTc/postgres
 thai       | postgres   | UTF8      | C.UTF-8     | C.UTF-8     |            | libc             | 
(9 строк)
```

* переключаемся на БД thai:
`postgres=# \c thai`
* смотрим схемы в БД:
`thai=# \dn`
* вывод:
```
        Список схем
  Имя   |     Владелец      
--------+-------------------
 book   | postgres
 public | pg_database_owner
(2 строки)
```
* Переключаем путь поиска в нашу схему:
`thai=# SET search_path=book;`
* вывод:
```
SET
```
* список таблиц:
`thai=# \dt`
* вывод:
```
             Список отношений
 Схема |     Имя      |   Тип   | Владелец 
-------+--------------+---------+----------
 book  | bus          | таблица | postgres
 book  | busroute     | таблица | postgres
 book  | busstation   | таблица | postgres
 book  | fam          | таблица | postgres
 book  | nam          | таблица | postgres
 book  | ride         | таблица | postgres
 book  | schedule     | таблица | postgres
 book  | seat         | таблица | postgres
 book  | seatcategory | таблица | postgres
 book  | tickets      | таблица | postgres
(10 строк)
```
* считаем кол-во всех записей в табличке tickets (это не обязательно "поездки"!)
`thai=# SELECT COUNT(*) FROM tickets;`
* вывод:
```
  count  
---------
 5185505
(1 строка)
```

