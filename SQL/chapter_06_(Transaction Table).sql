------------------------------------------------------------------------------------------------------------------------------------------
                           -------------------------Глава 6. Таблица переводов.-----------------------
------------------------------------------------------------------------------------------------------------------------------------------

DROP TABLE trans2;
CREATE TABLE trans2(
id_from INTEGER NOT NULL,
id_to INTEGER NOT NULL,
dat DATE NOT NULL,
val INTEGER NOT NULL);

LOCK TABLE Savalek.trans2 IN EXCLUSIVE MODE NOWAIT;

--Сначала находим ID таблицы.
select * from all_objects where object_name = 'TRANS';
--Затем находим ID сессии, которая блокирует эту таблицу.
select sid from v$lock where id1 = 188162 or id2 = 188556;
--Затем находим серийный номер сессии
select sid, serial# from v$session where sid = 134
--А потом прибиваем сессию к чертям. Параметр — sid || ',' || serial#
alter system kill session '134,9107' immediate

----Генерирование таблицы
TRUNCATE TABLE trans2;
INSERT INTO trans2
SELECT dbms_random.value(1, 3), --множество id_from
       dbms_random.value(1, 3), --множество id_to
       SUBSTR(CONCAT('00', cast(dbms_random.value(1, 19) AS INTEGER)), -2)||'/'||  --день
       SUBSTR(CONCAT('00', cast(dbms_random.value(5, 7) AS INTEGER)), -2)||'/'||   --месяц
       SUBSTR(CONCAT('0000', cast(dbms_random.value(2017, 2017) AS INTEGER)), -4), --год
       cast(dbms_random.value(1, 5) AS INTEGER) * 10 --сумма переводов
FROM dual
CONNECT BY LEVEL<=100;
DELETE FROM trans2
WHERE id_from = id_to;


INSERT INTO trans2 VALUES(1, 4, '19/07/2017', 1000000);

DELETE FROM trans2 WHERE dat = '19/07/2017' AND val = 1000000;
SELECT * FROM trans2;

----Таблица для хранения интервалов
DROP TABLE interval_state_acc;
CREATE TABLE interval_state_acc
(
id_acc INTEGER NOT NULL,
int_beg DATE,
int_end DATE,
state_acc INTEGER NOT NULL,
state_change INTEGER
);

----Просчёт периодов для всех транзакций (Единичный запрос)
TRUNCATE TABLE interval_state_acc;
INSERT INTO INTERVAL_STATE_ACC
  SELECT ID_ACC,
         LAG(DAT, 1) OVER(PARTITION BY ID_ACC ORDER BY DAT) AS INT_BEG,
         DAT AS INT_END,
         COALESCE(SUM(VAL)
                  OVER(PARTITION BY ID_ACC ORDER BY DAT ASC
                       ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING),
                  0) AS STATE_ACC,
         val AS state_change
    FROM (SELECT ID_ACC, DAT, SUM(VAL) VAL
            FROM (SELECT ID_ACC, DAT, SUM(VAL) VAL
                    FROM (SELECT ID_FROM AS ID_ACC, DAT, -VAL AS VAL
                            FROM trans2
                          UNION ALL
                          SELECT ID_TO AS ID_ACC, DAT, VAL AS VAL FROM trans2) TTT
                   GROUP BY ID_ACC, DAT
                  HAVING SUM(VAL) <> 0) TT
           GROUP BY GROUPING SETS((ID_ACC, DAT, VAL),(ID_ACC))) T;

SELECT * FROM INTERVAL_STATE_ACC;

----Обновление базы interval_state_acc (Часто выполняемый запрос)
DELETE FROM interval_state_acc
WHERE int_end > SYSDATE - INTERVAL '20' DAY
   OR int_beg > SYSDATE - INTERVAL '20' DAY;

INSERT INTO INTERVAL_STATE_ACC
  SELECT ID_ACC,
         COALESCE(LAG(DAT, 1) OVER(PARTITION BY ID_ACC ORDER BY DAT),
                  (SELECT ISA.INT_END
                     FROM INTERVAL_STATE_ACC ISA
                    WHERE ISA.ID_ACC = T.ID_ACC
                      AND ISA.INT_END =
                          (SELECT MAX(ISA2.INT_END)
                             FROM INTERVAL_STATE_ACC ISA2
                            WHERE ISA2.ID_ACC = ISA.ID_ACC))) AS INT_BEG,
         DAT AS INT_END,
         COALESCE(SUM(VAL)
                  OVER(PARTITION BY ID_ACC ORDER BY DAT ASC
                       ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING),
                  0) + COALESCE((SELECT ISA.STATE_ACC
                                   FROM INTERVAL_STATE_ACC ISA
                                  WHERE ISA.ID_ACC = T.ID_ACC
                                    AND ISA.INT_END =
                                        (SELECT MAX(ISA2.INT_END)
                                           FROM INTERVAL_STATE_ACC ISA2
                                          WHERE ISA2.ID_ACC = ISA.ID_ACC)) +
                                (SELECT ISA.STATE_CHANGE
                                   FROM INTERVAL_STATE_ACC ISA
                                  WHERE ISA.ID_ACC = T.ID_ACC
                                    AND ISA.INT_END =
                                        (SELECT MAX(ISA2.INT_END)
                                           FROM INTERVAL_STATE_ACC ISA2
                                          WHERE ISA2.ID_ACC = ISA.ID_ACC)),
                                0) AS STATE_ACC,
         VAL
    FROM (SELECT ID_ACC, DAT, SUM(VAL) VAL
            FROM (SELECT ID_ACC, DAT, SUM(VAL) AS VAL
                    FROM (SELECT TTTT.*,
                                 ROW_NUMBER() OVER(PARTITION BY ID_ACC ORDER BY DAT) AS ROW_NUM
                            FROM (SELECT ID_FROM AS ID_ACC, DAT, -VAL AS VAL
                                    FROM trans2
                                   WHERE DAT >= SYSDATE - INTERVAL '20' DAY
                                  UNION ALL
                                  SELECT ID_TO AS ID_ACC, DAT, VAL AS VAL
                                    FROM trans2
                                   WHERE DAT >= SYSDATE - INTERVAL '20' DAY) TTTT) TTT
                   GROUP BY ID_ACC, DAT
                  HAVING SUM(VAL) <> 0) TT
           GROUP BY GROUPING SETS((ID_ACC, DAT, VAL),(ID_ACC))) T;

SELECT * FROM INTERVAL_STATE_ACC;

----Представление для отображения периодов
CREATE OR REPLACE VIEW interval_state_acc_view AS
SELECT id_acc as "id",
       COALESCE(CAST(int_beg AS VARCHAR(10)), 'Начало Времён') AS "Начало периода",
       COALESCE(CAST(int_end AS VARCHAR(10)), 'Конец Времён') AS "Конец периода",
       state_acc AS "Состояние счета"
FROM interval_state_acc
ORDER BY id_acc, int_end;

SELECT * FROM interval_state_acc_view;
SELECT * FROM interval_state_acc ORDER BY id_acc, int_beg;

-----------------------------------------Вариант c MERGE-------------------------------------------
----Таблица для хранения интервалов (Merge)
DROP TABLE interval_state_acc_merge2;
CREATE TABLE interval_state_acc_merge2
(
int_num INTEGER NOT NULL,
id_acc INTEGER NOT NULL,
int_beg DATE,
int_end DATE,
state_acc INTEGER NOT NULL,
state_change INTEGER
);

----Просчёт периодов для всех транзакций (Единичный запрос) (Merge)
TRUNCATE TABLE interval_state_acc_merge2;
INSERT INTO interval_state_acc_merge2
  SELECT row_number() OVER(PARTITION BY id_acc ORDER BY DAT) int_num,
         ID_ACC,
         LAG(DAT, 1) OVER(PARTITION BY ID_ACC ORDER BY DAT) AS INT_BEG,
         DAT AS INT_END,
         COALESCE(SUM(VAL)
                  OVER(PARTITION BY ID_ACC ORDER BY DAT ASC
                       ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING),
                  0) AS STATE_ACC,
         val AS state_change
    FROM (SELECT ID_ACC, DAT, SUM(VAL) VAL
            FROM (SELECT ID_ACC, DAT, SUM(VAL) VAL
                    FROM (SELECT ID_FROM AS ID_ACC, DAT, -VAL AS VAL
                            FROM trans2
                          UNION ALL
                          SELECT ID_TO AS ID_ACC, DAT, VAL AS VAL FROM trans2) TTT
                   GROUP BY ID_ACC, DAT
                  HAVING SUM(VAL) <> 0) TT
           GROUP BY GROUPING SETS((ID_ACC, DAT, VAL),(ID_ACC))) T;

SELECT * FROM interval_state_acc_merge2;
--Function (Merge) --(Не участвует в работе)
CREATE OR REPLACE FUNCTION GET_LAST_DATE(ID_ACC IN NUMBER) RETURN DATE IS
BEGIN
  RETURN(
       SELECT MAX(DATE)
       FROM interval_state_acc_merge2 ISA
       WHERE ISA.ID_ACC = ID_ACC
       AND INT_END <= SYSDATE - INTERVAL '20' DAY);
END GET_LAST_DATE;

SELECT GET_LAST_DATE(1) FROM dual;

---view
CREATE OR REPLACE VIEW new_isa AS
SELECT O.*, MAX(int_num) OVER(PARTITION BY id_acc) AS int_max
FROM (
        SELECT ROW_NUMBER() OVER(PARTITION BY ID_ACC ORDER BY DAT) + COALESCE(((SELECT MAX(INT_NUM) FROM interval_state_acc_merge2 ISA
                                                                        WHERE ISA.ID_ACC = T.ID_ACC AND ISA.INT_END <= SYSDATE - INTERVAL '20' DAY)), 0) INT_NUM,
               ID_ACC,
               COALESCE(LAG(DAT, 1) OVER(PARTITION BY ID_ACC ORDER BY DAT),
                       (SELECT MAX(INT_END) FROM interval_state_acc_merge2 ISA
                        WHERE ISA.ID_ACC = T.ID_ACC  AND ISA.INT_END <= SYSDATE - INTERVAL '20' DAY)
                        ) AS INT_BEG,
               DAT AS INT_END,
               COALESCE(SUM(VAL) OVER(PARTITION BY ID_ACC ORDER BY DAT ASC ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING), 0) +
                        COALESCE((SELECT ISA.STATE_ACC + ISA.STATE_CHANGE
                                  FROM interval_state_acc_merge2 ISA
                                  WHERE ISA.ID_ACC = T.ID_ACC
                                  AND INT_END = (SELECT MAX(INT_END) FROM interval_state_acc_merge2 ISA
                                                 WHERE ISA.ID_ACC = T.ID_ACC AND ISA.INT_END <= SYSDATE - INTERVAL '20' DAY)),
                        0) AS STATE_ACC,
               VAL AS state_change
          FROM (SELECT ID_ACC, DAT, SUM(VAL) VAL
                  FROM (SELECT ID_ACC, DAT, SUM(VAL) AS VAL
                        FROM (SELECT TTTT.*, ROW_NUMBER() OVER(PARTITION BY ID_ACC ORDER BY DAT) AS ROW_NUM
                              FROM (SELECT ID_FROM AS ID_ACC, DAT, -VAL AS VAL
                                    FROM trans2
                                    WHERE DAT >= SYSDATE - INTERVAL '20' DAY
                                    UNION ALL
                                    SELECT ID_TO AS ID_ACC, DAT, VAL AS VAL
                                    FROM trans2
                                    WHERE DAT >= SYSDATE - INTERVAL '20' DAY
                                    ) TTTT
                             ) TTT
                        GROUP BY ID_ACC, DAT
                        HAVING SUM(VAL) <> 0) TT
                 GROUP BY GROUPING SETS((ID_ACC, DAT, VAL),(ID_ACC))) T
     ) O;


--merge
MERGE INTO interval_state_acc_merge2 isa
USING ( SELECT * FROM new_isa) n_isa
ON ( isa.id_acc = n_isa.id_acc AND isa.int_num = n_isa.int_num)
  WHEN MATCHED THEN UPDATE
    SET isa.int_beg = n_isa.int_beg,
        isa.int_end = n_isa.int_end,
        isa.state_acc = n_isa.state_acc,
        isa.state_change = n_isa.state_change
        --WHERE isa.int_num = n_isa.int_num
    --DELETE WHERE isa.int_num > n_isa.int_max
WHEN NOT MATCHED THEN INSERT (isa.int_num, isa.id_acc, isa.int_beg, isa.int_end, isa.state_acc, isa.state_change)
  VALUES(n_isa.int_num, n_isa.id_acc, n_isa.int_beg, n_isa.int_end, n_isa.state_acc, n_isa.state_change);

--вместе с merge (чистка старых записей и удаление не актуальных аккаунтов)
DELETE FROM interval_state_acc_merge2 i
WHERE int_num > (SELECT MAX(int_num) FROM new_isa ii WHERE i.id_acc = ii.id_acc)
OR 0 = (SELECT COUNT(*) FROM new_isa ii WHERE i.id_acc = ii.id_acc);

--temp#################
SELECT * FROM interval_state_acc_merge2;
SELECT * FROM interval_state_acc_merge2_view;

INSERT INTO trans2 VALUES(1, 4, '19/07/2017', 1000000);

DELETE FROM trans2 WHERE val = 1000000;
COMMIT;
SELECT * FROM trans2;
--temp#################
----Представление для отображения периодов (Merge)
CREATE OR REPLACE VIEW interval_state_acc_merge2_view AS
SELECT id_acc as "id",
       COALESCE(CAST(int_beg AS VARCHAR(10)), 'Начало Времён') AS "Начало периода",
       COALESCE(CAST(int_end AS VARCHAR(10)), 'Конец Времён') AS "Конец периода",
       state_acc AS "Состояние счета"
FROM interval_state_acc_merge2
ORDER BY id_acc, int_end;

SELECT * FROM interval_state_acc_merge2_view;
SELECT * FROM interval_state_acc ORDER BY id_acc, int_beg;
