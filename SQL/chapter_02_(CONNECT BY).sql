------------------------------------------------------------------------------------------------------------------------------------------
           ---------------------------Глава 2. Таблица bacteriums: CONNECT BY, WITH (рекурсия) ------------------------------
------------------------------------------------------------------------------------------------------------------------------------------
DROP SEQUENCE bact_id;

CREATE SEQUENCE bact_id
INCREMENT BY 1
START WITH -1
MINVALUE -1
MAXVALUE 9999
NOCYCLE;

-----
DROP TABLE Bacteriums;

CREATE TABLE Bacteriums(
b_id INTEGER NOT NULL,
p_id INTEGER,
bname VARCHAR2(30),
weight INTEGER);

INSERT INTO Bacteriums VALUES(bact_id.nextval, NULL, 'Bacterium #'||bact_id.currval||'_adam', 7);


INSERT INTO Bacteriums
SELECT bact_id.nextval,
       dbms_random.value((SELECT MIN(b_id) FROM Bacteriums), bact_id.currval - 1),
       'Bacterium #'||bact_id.currval,
       dbms_random.value(1,7)
FROM dual
CONNECT BY LEVEL <=10;

INSERT INTO Bacteriums VALUES(bact_id.nextval, NULL, 'Bacterium #'||bact_id.currval||'_null_weight', NULL);
INSERT INTO Bacteriums VALUES(bact_id.nextval, bact_id.currval - 1, 'Bacterium #'||bact_id.currval||'_null_weight_sun', NULL);
UPDATE Bacteriums SET bname = REPLACE(bname, 'sun', 'son'), weight = 1 WHERE b_id = 12;
--------------------------------------------------------
SELECT * FROM Bacteriums;


--TREE with CONNECT BY
--Отобразить:
--дерево происхождения всех бактерий,
--вес отдельно взятой бактерии, вес самой бактерии + вес всех ее потомком,
--вес самой бактерии + вес всех ее предков,
--перечислить через запятую предков клетки
SELECT LPAD('+——', 10*(LEVEL-1), ' ')||bname AS Tree, b_id AS "ID", p_id as  "PARENT",
       weight,
       (SELECT SUM(weight)
       FROM Bacteriums bb
       START WITH bb.b_id = b.b_id
       CONNECT BY PRIOR b_id = p_id) descen_sum,
       (SELECT SUM(weight)
       FROM Bacteriums bb
       START WITH bb.b_id = b.b_id
       CONNECT BY PRIOR p_id = b_id) prior_sum,
       --LEVEL lev,
       --CONNECT_BY_ISLEAF leaf,
       --CONNECT_BY_ROOT bname root,
       CASE
       WHEN (b_id = CONNECT_BY_ROOT b_id)
       THEN NULL
       ELSE SUBSTR(SYS_CONNECT_BY_PATH(PRIOR bname, ', '), 5)
       END life_path
FROM bacteriums b
START WITH p_id IS NULL
CONNECT BY PRIOR b_id = p_id
ORDER SIBLINGS BY bname;

--TREE with WITH RECURSIVE
--Отобразить:
--дерево происхождения всех бактерий,
--вес отдельно взятой бактерии, вес самой бактерии + вес всех ее потомком,
--вес самой бактерии + вес всех ее предков,
--перечислить через запятую предков клетки
WITH Rec (b_id, p_id, bname, lvl, weight, psum, tPath)
     AS (
        SELECT b_id, p_id, bname, 1 , weight, weight AS psum, bname AS tPath
        FROM Bacteriums WHERE p_id IS NULL
        UNION ALL
        SELECT b.b_id, b.p_id, b.bname, r.lvl + 1,
               b.weight, COALESCE(r.psum, 0) + COALESCE(b.weight, 0),
               r.tPath||CAST(', '||b.bname AS VARCHAR2(90)) AS tPath
        FROM Bacteriums b INNER JOIN Rec r ON b.p_id = r.b_id
        )
        SEARCH DEPTH FIRST BY b_id SET ord
SELECT LPAD('+——', 10*(lvl-1), ' ')||bname AS Tree,-- lvl, ord,
       b_id AS "ID",
       p_id AS "PARENT",
       weight,
       (
       SELECT SUM(weight) --сумма масс клетки и ее потомков
       FROM Bacteriums b
       WHERE b_id IN (
                     SELECT b_id --список id состоящей из id самой клетки и ее потомков
                     FROM Rec rr
                     WHERE rr.ord >= r.ord --где ord на ходится между самой клеткой(включительно) и близжайшим НЕ потомком(не включительно) или конца таблицы при отсутствии НЕ потомка
                     AND rr.ord < COALESCE (
                                           (SELECT min(ord) FROM REC rrr WHERE rrr.ord > r.ord AND rrr.lvl <= r.lvl), --поиск близжайшего НЕ потомка или
                                           (SELECT MAX(ord) FROM Rec) + 1 --конца таблицы
                                           )
                     )
       ) AS descen_sum,
       psum AS prior_sum,
       REPLACE(REPLACE(tPath, ', '||bname), bname) AS life_path
FROM Rec r
ORDER BY ord;
