------------------------------------------------------------------------------------------------------------------------------------------
                    --------------------------------------Глава 1. Начало------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------

-------------------Последовательноси-------------
DROP SEQUENCE m_seq;

CREATE SEQUENCE m_seq
INCREMENT BY 1
START WITH 1
MAXVALUE 9999
NOCYCLE;

--------------------Функции-----------------------
CREATE OR REPLACE FUNCTION get_id RETURN VARCHAR IS
BEGIN
   RETURN SUBSTR(CONCAT('000', m_seq.nextval), -4);
END;
---------------Удаление таблиц-------------------
DROP TABLE staff;
DROP TABLE shops;
----------------Создание таблиц-------------------
CREATE TABLE shops(
id_shop VARCHAR(4) NOT NULL,
city VARCHAR(20) NOT NULL,
open_time DATE,
close_time DATE,
PRIMARY KEY (id_shop)
);


CREATE TABLE staff(
id_worker VARCHAR(4) NOT NULL,
id_shop VARCHAR(4) NOT NULL,
salary INTEGER,
wname VARCHAR(15) NOT NULL,
age INTEGER,
PRIMARY KEY (id_worker),
CONSTRAINT work_in FOREIGN KEY(id_shop) REFERENCES shops
);
---------------Заполнение таблиц-----------------
INSERT INTO shops VALUES(get_id(), 'Moscow',       to_date('08:00', 'hh24:mi'), to_date('18:00', 'hh24:mi'));
INSERT INTO shops VALUES(get_id(), 'Rostov',       to_date('09:00', 'hh24:mi'), to_date('20:00', 'hh24:mi'));
INSERT INTO shops VALUES(get_id(), 'Samara',       to_date('08:00', 'hh24:mi'), to_date('18:00', 'hh24:mi'));
INSERT INTO shops VALUES(get_id(), 'Omsk',         to_date('09:00', 'hh24:mi'), to_date('20:00', 'hh24:mi'));
INSERT INTO shops VALUES(get_id(), 'Volgograd',    to_date('09:30', 'hh24:mi'), to_date('22:00', 'hh24:mi'));
INSERT INTO shops VALUES(get_id(), 'Krasnodar',    to_date('08:00', 'hh24:mi'), to_date('18:00', 'hh24:mi'));
INSERT INTO shops VALUES(get_id(), 'Strange_city', to_date('05:00', 'hh24:mi'), to_date('23:00', 'hh24:mi'));

INSERT INTO staff VALUES(get_id(), (SELECT id_shop FROM shops WHERE city = 'Rostov'),          12000,       'Олег',    57 );
INSERT INTO staff VALUES(get_id(), (SELECT id_shop FROM shops WHERE city = 'Samara'),          43000,       'Aня',     18 );
INSERT INTO staff VALUES(get_id(), (SELECT id_shop FROM shops WHERE city = 'Krasnodar'),       46000,       'Кирилл',  36 );
INSERT INTO staff VALUES(get_id(), (SELECT id_shop FROM shops WHERE city = 'Samara'),          23000,       'Саша',    45 );
INSERT INTO staff VALUES(get_id(), (SELECT id_shop FROM shops WHERE city = 'Volgograd'),       16000,       'Даша',    34 );
INSERT INTO staff VALUES(get_id(), (SELECT id_shop FROM shops WHERE city = 'Rostov'),          65000,       'Лена',    34 );
INSERT INTO staff VALUES(get_id(), (SELECT id_shop FROM shops WHERE city = 'Moscow'),          32000,       'Вика',    37 );
INSERT INTO staff VALUES(get_id(), (SELECT id_shop FROM shops WHERE city = 'Omsk'),            54000,       'Никита',  28 );
INSERT INTO staff VALUES(get_id(), (SELECT id_shop FROM shops WHERE city = 'Moscow'),          32000,       'Олег',    45 );
INSERT INTO staff VALUES(get_id(), (SELECT id_shop FROM shops WHERE city = 'Rostov'),          12000,       'Саша',    30 );
INSERT INTO staff VALUES(get_id(), (SELECT id_shop FROM shops WHERE city = 'Samara'),          43000,       'Олег',    20 );
INSERT INTO staff VALUES(get_id(), (SELECT id_shop FROM shops WHERE city = 'Volgograd'),       32000,       'Надя',    19 );

-----------------Представления-----------------
CREATE OR REPLACE VIEW view_shops AS
SELECT id_shop, city, to_char(open_time, 'hh24:mi') OPEN_IN, to_char(close_time, 'hh24:mi') CLOSE_IN
FROM shops;
---------------Вывод таблиц----------------------
SELECT * FROM view_shops;
SELECT * FROM staff ORDER BY id_shop;
SELECT * FROM staff NATURAL JOIN view_shops;



--------------------------------------------------SELECT тесты------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------

--DISTINCT
-- Вывести список тех имен, которые имются у сотрудников
SELECT DISTINCT wname AS Имена_сотрудников
FROM staff;

--COUNT(colomn_name), INNER JOIN, UNION, NOT IN, GROUP BY, ORDER BY
-- Вывести общее количество сотрудников в каждом городе.
-- Сортировать по убыванию кол-ва сотрудников
SELECT city, COUNT(id_worker) Количество_сотрудников
FROM shops s INNER JOIN staff w ON s.id_shop = w.id_shop
GROUP BY city
UNION
SELECT city, 0
FROM shops
WHERE id_shop NOT IN (SELECT DISTINCT id_shop FROM staff)
ORDER BY 2 DESC;

--NATURAL JOIN
-- Вывести всех сотрудников с полной информацией о месте их работы
SELECT *
FROM staff  NATURAL JOIN view_shops
ORDER BY city;


--HAVING
-- Для всех магазтнов в которых средний возраст сотрудников не превышает 30 лет
-- Вывести: Город в котором находиться магазин, средний возраст с точность двух знаков после запятой
SELECT city, CAST(AVG(age) AS NUMERIC(5,2)) avg_age
FROM shops s, staff w
WHERE s.id_shop = w.id_shop
GROUP BY city
HAVING AVG(age) <= 30;


--GROUPING SETS
-- Вывести среднюю з/п сотрудника для каждого отдельно взятого магазина
-- и среднюю з/п для всех сотрудников компании
SELECT COALESCE(city, 'Сред. з\п всех') || ' :' AS city, CAST(AVG(salary) AS NUMERIC(10)) AS avg_salary
FROM staff NATURAL JOIN shops
GROUP BY
GROUPING SETS ((city, id_shop),());

--ROLLUP
-- ???
SELECT wname, open_time, close_time, COUNT(*)
FROM staff NATURAL JOIN shops
GROUP BY ROLLUP(wname, open_time, close_time);
