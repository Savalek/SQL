----------в любой моменный времени данные в таблице будут соответствовать 
----------данным имеющимся в таблице на начало транзакции
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
SELECT * FROM savalek.people;
COMMIT;

----------в любой моменный времени данные в таблице могут
----------быть изменены другой транзакцией
SET TRANSACTION ISOLATION LEVEL READ COMMITTED; --по умолчанию в Oracle
SELECT * FROM savalek.people;
COMMIT;

              --<<<<<<<<<<<<<<<<<<<<блокировки>>>>>>>>>>>>>>>>>>>--
LOCK TABLE Savalek.People IN ROW SHARE MODE NOWAIT;          --(1)
LOCK TABLE Savalek.People IN ROW EXCLUSIVE MODE NOWAIT;      --(2)
LOCK TABLE Savalek.People IN SHARE MODE NOWAIT;              --(3)
LOCK TABLE Savalek.People IN SHARE ROW EXCLUSIVE MODE NOWAIT;--(4)
LOCK TABLE Savalek.People IN EXCLUSIVE MODE NOWAIT;          --(5)
              --<<<<<<<<<<<<<<<<<<<<блокировки>>>>>>>>>>>>>>>>>>>--
--SELECT
SELECT * FROM Savalek.People;
--UPDATE
UPDATE Savalek.People SET NAME = 'Кирилл'
WHERE id_p = (SELECT MIN(id_p) FROM Savalek.people);
--INSERT
INSERT INTO savalek.people
SELECT savalek.get_people_id, 'Oleg', dbms_random.value(1, 100)
FROM dual
CONNECT BY LEVEL <= 1;
--DELETE
DELETE FROM Savalek.People 
WHERE NAME = 'Кирилл';

COMMIT;

SELECT * FROM savalek.people;
