------------------------------------------------------------------------------------------------------------------------------------------
                       -------------------------Глава 3. PIVOT, UNPIVOT и MERGE.-----------------------
------------------------------------------------------------------------------------------------------------------------------------------

--------------------------------Таблцица ZOO---
DROP TABLE ZOO;

CREATE TABLE ZOO(
animal VARCHAR2(20) NOT NULL,
zoo_name VARCHAR(30) NOT NULL,
cnt INTEGER NOT NULL);


----------------Заполнение-----
INSERT INTO ZOO VALUES('Обезьяна',       'Центральный Зоопарк', 15);
INSERT INTO ZOO VALUES('Слон',           'Центральный Зоопарк', 3);
INSERT INTO ZOO VALUES('Жираф',          'Центральный Зоопарк', 5);
INSERT INTO ZOO VALUES('Орёл',           'Центральный Зоопарк', 2);
INSERT INTO ZOO VALUES('Носорог',        'Центральный Зоопарк', 3);
INSERT INTO ZOO VALUES('Гиена',          'Центральный Зоопарк', 15);
INSERT INTO ZOO VALUES('Лев',            'Центральный Зоопарк', 3);
INSERT INTO ZOO VALUES('Обезьяна',       'Зоолэнд',             7);
INSERT INTO ZOO VALUES('Слон',           'Зоолэнд',             3);
INSERT INTO ZOO VALUES('Жираф',          'Зоолэнд',             8);
INSERT INTO ZOO VALUES('Орёл',           'Зоолэнд',             12);
INSERT INTO ZOO VALUES('Носорог',        'Зоолэнд',             9);
INSERT INTO ZOO VALUES('Гиена',          'Зоолэнд',             23);
INSERT INTO ZOO VALUES('Лев',            'Зоолэнд',             17);
INSERT INTO ZOO VALUES('Лось',           'Зоолэнд',             12);
INSERT INTO ZOO VALUES('Какаду',         'Зоолэнд',             23);
INSERT INTO ZOO VALUES('Рысь',           'Зоолэнд',             19);
INSERT INTO ZOO VALUES('Обезьяна',       'Тихая поляна',        5);
INSERT INTO ZOO VALUES('Жираф',          'Тихая поляна',        2);
INSERT INTO ZOO VALUES('Носорог',        'Тихая поляна',        1);
INSERT INTO ZOO VALUES('Лось',           'Тихая поляна',        3);

----------------------------
SELECT * FROM ZOO;

--1_1 (PIVOT)
SELECT ANIMAL, COALESCE(zoo1_cnt, 0) "Центральный Зоопарк", COALESCE(zoo2_cnt, 0) "Зоолэнд", COALESCE(zoo3_cnt, 0) "Тихая поляна"
FROM ZOO
PIVOT(sum(cnt) cnt FOR zoo_name IN('Центральный Зоопарк' zoo1, 'Зоолэнд' zoo2, 'Тихая поляна' zoo3));

--1_2 (PIVOT)
SELECT zoo_name, Monkey_cnt Monkey, Elephant_cnt Elephant,
                 Giraffe_cnt Giraffe, Rhinoceros_cnt Rhinoceros,  Hyena_cnt Hyena,
                 Lion_cnt Lion, Cockatoo_cnt Cockatoo,  Elk_cnt Elk,  Eagle_cnt Eagle,  Lynx_cnt Lynx
FROM ZOO
PIVOT (SUM(cnt) AS cnt FOR animal IN ('Обезьяна' Monkey, 'Слон' Elephant, 'Жираф' Giraffe,
                                     'Носорог' Rhinoceros, 'Гиена' Hyena, 'Лев' Lion,
                                     'Какаду' Cockatoo, 'Лось' Elk, 'Орёл' Eagle, 'Рысь' Lynx));

----------MERGE----


SELECT * FROM Zoo;--Таблица до изменения

--Поступление животных на временное пользование
MERGE INTO ZOO z
USING (SELECT 'Орёл' animal, 'Центральный Зоопарк' zoo_name,  100 cnt FROM dual
       UNION ALL
       SELECT 'Орёл',        'Зоолэнд',                       200 FROM dual
       UNION ALL
       SELECT 'Рысь',        'Тихая поляна',                  100 FROM dual) an
ON (z.zoo_name = an.zoo_name AND z.animal = an.animal)
WHEN MATCHED THEN
  UPDATE SET z.cnt = z.cnt + an.cnt
WHEN NOT MATCHED THEN
  INSERT(z.animal,  z.zoo_name,  z.cnt)
  VALUES(an.animal, an.zoo_name, an.cnt);

SELECT * FROM Zoo;--отобразить временное изменение

MERGE INTO ZOO z
USING (SELECT 'Орёл' animal, 'Центральный Зоопарк' zoo_name,  100 cnt FROM dual
       UNION ALL
       SELECT 'Орёл',        'Зоолэнд',                       200 FROM dual
       UNION ALL
       SELECT 'Рысь',        'Тихая поляна',                  100 FROM dual) an
ON (z.zoo_name = an.zoo_name AND z.animal = an.animal)
WHEN MATCHED THEN
  UPDATE SET z.cnt = z.cnt - an.cnt
  DELETE WHERE z.cnt = 0
WHEN NOT MATCHED THEN
  INSERT(z.animal,  z.zoo_name,  z.cnt)
  VALUES(an.animal, an.zoo_name, an.cnt);

SELECT * FROM Zoo;--отобразить конечный результат


--------------------------------Таблица Stock-----
DROP TABLE stocks;

CREATE TABLE Stocks(
city VARCHAR2(20) NOT NULL,
paint INTEGER NOT NULL,
board INTEGER NOT NULL,
toy INTEGER NOT NULL,
PC INTEGER NOT NULL
);


INSERT INTO Stocks VALUES('Ростов', 100, 200, 300, 400);
INSERT INTO Stocks VALUES('Москва', 500, 600, 700, 800);
---------------------------

SELECT * FROM Stocks;

--2 (UNPIVOT)
SELECT * FROM Stocks
UNPIVOT (cnt FOR type_ IN (paint, board, toy, pc));
