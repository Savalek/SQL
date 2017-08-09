------------------------------------------------------------------------------------------------------------------------------------------
                           -------------------------Глава 5. Аналитические функции.-----------------------
------------------------------------------------------------------------------------------------------------------------------------------
--приверы с сайта:

Create table PersonA(Tbn number primary key, name varchar2(20), otd number, sal number);
--Табельный номер , имя, отдел , зарплата

Insert into PersonA(Tbn,name,otd,sal) values(1, 'Аня',10,9000);
Insert into PersonA(Tbn,name,otd,sal) values(2, 'Саша',10,5500);
Insert into PersonA(Tbn,name,otd,sal) values(3, 'Таня',10,7000);
Insert into PersonA(Tbn,name,otd,sal) values(4, 'Ваня',20,2300);
Insert into PersonA(Tbn,name,otd,sal) values(5, 'Олег',20,4300);
Insert into PersonA(Tbn,name,otd,sal) values(6, 'Коля',20,3900);
Insert into PersonA(Tbn,name,otd,sal) values(7, 'Таня',30,7000);
Insert into PersonA(Tbn,name,otd,sal) values(8, 'Макс',30,9000);
Insert into PersonA(Tbn,name,otd,sal) values(9, 'Таня',30,8500);
Insert into PersonA(Tbn,name,otd,sal) values(10,'Макс',30,9900);
Insert into PersonA(Tbn,name,otd,sal) values(11,'Олег',30,9900);
Insert into PersonA(Tbn,name,otd,sal) values(12,'Макс',30,9900);
Insert into PersonA(Tbn,name,otd,sal) values(13,'Макс',30,9900);
Insert into PersonA(Tbn,name,otd,sal) values(14,'Макс',30,9900);
Insert into PersonA(Tbn,name,otd,sal) values(15,'Макс',30,9900);
Insert into PersonA(Tbn,name,otd,sal) values(16,'Макс',30,7000);
Insert into PersonA(Tbn,name,otd,sal) values(17,'Таня',30,3500);


--Запросы списка лидеров
--Первые три сотрудника с самой высокой зарплатой по отделам (партишен по отделу)
select *
from (
     select NAME, otd, sal, row_number() over (partition by otd order by sal desc) AS num
     from personA
     )
where num<4;

--Более корректно
select *
from (
     select NAME, otd, sal, rank() over (partition by otd order by sal desc) as num
     from personA
     )
where num<4;

--По наименованию (партишен по отделу) сортировка по name
select *
from (
     select NAME, otd, sal, row_number() over (partition by otd order by name) as num
     from personA
     )
where num<4;

--Накопительный итог по зарплате
select NAME, otd, sal, sum(sal) over (partition by otd order by sal) as num
from personA;

--Среднее по зарплате в рамках отдела
select NAME, otd, sal,  avg(sal) over (partition by otd order by sal) as num
from personA;

--Демонстрация работы lag, leed - сотрудник , отдел , зарплата , сотрудник с более большей заплатой (maxsl),
--сотрудник с менее меньшей заплатой чем данный(minsl) в рамках отдела
select NAME, otd, sal,
       lead(NAME, 1) over (partition by otd order by sal) as maxsl,
       lag(name,1) over (partition by otd order by sal) as minsl
from personA;


--запрос демонстрирует конструкцию окна в рамках отдела , среднее по зарплате,
--вычисляется, не только в рамках отдела , но так же и в рамках окна из 3х строк
SELECT NAME, otd, sal,
       AVG(sal) OVER(
                     partition by otd
                     order by sal
                     ROWS
                     BETWEEN 1 PRECEDING
                     AND
                     CURRENT ROW
                     ) as num
from personA;


--этот запрос демонстрирует применение аналитических функций first_value last_value
select NAME, otd, sal,
       first_value(name) over (partition by otd) as maxsl,
       last_value(name) over (partition by otd) as minsl
from personA;

---------------------мои примеры:
CREATE TABLE pers(
ID INTEGER PRIMARY KEY,
NAME VARCHAR2(20),
salary INTEGER,
dept VARCHAR(10)
);

INSERT INTO pers (id, NAME) VALUES(1,  'Коля');
INSERT INTO pers (id, NAME) VALUES(2,  'Антон');
INSERT INTO pers (id, NAME) VALUES(3,  'Кирилл');
INSERT INTO pers (id, NAME) VALUES(4,  'Таня');
INSERT INTO pers (id, NAME) VALUES(5,  'Антон');
INSERT INTO pers (id, NAME) VALUES(6,  'Коля');
INSERT INTO pers (id, NAME) VALUES(7,  'Кирилл');
INSERT INTO pers (id, NAME) VALUES(8,  'Саша');
INSERT INTO pers (id, NAME) VALUES(9,  'Кирилл');
INSERT INTO pers (id, NAME) VALUES(10, 'Антон');
INSERT INTO pers (id, NAME) VALUES(11, 'Кирилл');
INSERT INTO pers (id, NAME) VALUES(12, 'Аня');
INSERT INTO pers (id, NAME) VALUES(13, 'Антон');
INSERT INTO pers (id, NAME) VALUES(14, 'Антон');
INSERT INTO pers (id, NAME) VALUES(15, 'Саша');
INSERT INTO pers (id, NAME) VALUES(16, 'Аня');
INSERT INTO pers (id, NAME) VALUES(17, 'Коля');
INSERT INTO pers (id, NAME) VALUES(18, 'Кирилл');
INSERT INTO pers (id, NAME) VALUES(19, 'Таня');
INSERT INTO pers (id, NAME) VALUES(20, 'Кирилл');
INSERT INTO pers (id, NAME) VALUES(21, 'Аня');
INSERT INTO pers (id, NAME) VALUES(22, 'Таня');
INSERT INTO pers (id, NAME) VALUES(23, 'Антон');
INSERT INTO pers (id, NAME) VALUES(24, 'Аня');
INSERT INTO pers (id, NAME) VALUES(25, 'Кирилл');
INSERT INTO pers (id, NAME) VALUES(26, 'Аня');
INSERT INTO pers (id, NAME) VALUES(27, 'Коля');
INSERT INTO pers (id, NAME) VALUES(28, 'Саша');
INSERT INTO pers (id, NAME) VALUES(29, 'Аня');
INSERT INTO pers (id, NAME) VALUES(30, 'Антон');
INSERT INTO pers (id, NAME) VALUES(31, 'Кирилл');
INSERT INTO pers (id, NAME) VALUES(32, 'Аня');
INSERT INTO pers (id, NAME) VALUES(33, 'Таня');
INSERT INTO pers (id, NAME) VALUES(34, 'Кирилл');
INSERT INTO pers (id, NAME) VALUES(35, 'Антон');

UPDATE pers s SET
dept = CASE (
             SELECT dptn
             FROM  (
                   SELECT p.*, NTILE(3) OVER(ORDER BY ID) AS dptn
                   FROM pers p
                   ) t
             WHERE t.id = s.id
             )
       WHEN 1
         THEN 'Ростов'
       WHEN 2
         THEN 'Таганрог'
       WHEN 3
         THEN 'Азов'
       END,
salary = CAST(dbms_random.value(1,9) AS INTEGER)*1000;

SELECT * FROM Pers;

--Посчитать для среднюю зарплату для текущей позиции и двух крайних(по одной слева и справа) в рамках одного отдела
SELECT ID, NAME, dept, salary,
       AVG(salary) OVER(
                        PARTITION BY dept
                        ORDER BY salary
                        ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
                       ) AS avg_salary
FROM pers;

--Посчитать корреляцию между зарплатой и размером премии в каждом отделе
SELECT ID, NAME, dept, salary,
       cast(prize AS NUMERIC) AS prize,
       CAST(CORR(salary, prize) OVER(PARTITION BY dept ORDER BY id) AS NUMERIC(5,3)) AS correlation
FROM (
      SELECT p.*, salary * (dbms_random.value(1, 3)/10) AS prize
      FROM pers p
      ) t;

--посчитать сумму зарплат для текущего и для предыдущих у которых зп не МЕНЬШЕ 1000 относительно текущей
--посчитать сумму зарплат для текущего и для предыдущих у которых зп не БОЛЬШЕ 1000 относительно текущей
SELECT ID, NAME, dept, salary,
       SUM(salary) OVER(PARTITION BY dept ORDER BY salary ASC RANGE 1000 PRECEDING ) AS summ_before,
       SUM(salary) OVER(PARTITION BY dept ORDER BY salary DESC RANGE 1000 PRECEDING) AS summ_after
FROM Pers p

--для каждой строки отобразить имя чея з/п меньше и больше з/п у текущей строки
--отобразить имя целовека с самой большой/малькой з/п в отделе
SELECT ID, NAME, dept, salary
       LEAD(NAME) OVER(PARTITION BY dept ORDER BY salary) ,
       LAG(NAME) OVER(PARTITION BY dept ORDER BY salary)
FROM Pers;
ORDER BY dept, salary;
