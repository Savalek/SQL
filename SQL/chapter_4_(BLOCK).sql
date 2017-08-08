------------------------------------------------------------------------------------------------------------------------------------------
                             -------------------------Глава 4. Блокировки.-----------------------
------------------------------------------------------------------------------------------------------------------------------------------

DROP SEQUENCE people_seq;

CREATE SEQUENCE people_seq
INCREMENT BY 1
START WITH 1
MAXVALUE 999999
CYCLE;

CREATE OR REPLACE FUNCTION get_people_id RETURN VARCHAR IS
BEGIN
   RETURN SUBSTR(CONCAT('00000', people_seq.nextval), -6);
END;

-----Создание таблицы---
DROP TABLE People;

CREATE TABLE People(
id_p VARCHAR2(6) NOT NULL,
NAME VARCHAR2(50),
age INTEGER,
PRIMARY KEY (id_p));

------заполнение PEOPLE-----
TRUNCATE TABLE People;

              --<<<<<<<<<<<<<<<<<<<<блокировки>>>>>>>>>>>>>>>>>>>--
                                                            | 1 | 2 | 3 | 4 | 5 | sel | ins | upd | del |
LOCK TABLE People IN ROW SHARE MODE NOWAIT;          -- <1> | 1 | 2 | 3 | 4 |   | sel | ins | upd | del |
LOCK TABLE People IN ROW EXCLUSIVE MODE NOWAIT;      -- <2> | 1 | 2 |   |   |   | sel | ins | upd | del |
LOCK TABLE People IN SHARE MODE NOWAIT;              -- <3> | 1 |   | 3 |   |   | sel |     |     |     |
LOCK TABLE People IN SHARE ROW EXCLUSIVE MODE NOWAIT;-- <4> | 1 |   |   |   |   | sel |     |     |     |
LOCK TABLE People IN EXCLUSIVE MODE NOWAIT;          -- <5> |   |   |   |   |   | sel |     |     |     |
              --<<<<<<<<<<<<<<<<<<<<блокировки>>>>>>>>>>>>>>>>>>>--
SELECT * FROM People;

INSERT INTO people
SELECT get_people_id, 'Oleg', dbms_random.value(1, 100)
FROM dual
CONNECT BY LEVEL <= 1;
COMMIT;
--------вывод таблицы----
SELECT * FROM People;
SELECT max(id_p) max_id FROM People;
