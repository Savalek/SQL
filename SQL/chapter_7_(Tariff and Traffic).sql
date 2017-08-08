------------------------------------------------------------------------------------------------------------------------------------------
                           -------------------------Глава 7. Тарифы и Трафик. 100 дневный период.-----------------------
------------------------------------------------------------------------------------------------------------------------------------------
DROP TABLE Tariff;
CREATE TABLE Tariff
(
id_user NUMBER(10) NOT NULL,
tar_dat DATE NOT NULL,
lim NUMBER(20) CHECK(lim >= 0),
PRIMARY KEY(id_user, tar_dat)
);

DROP TABLE Traffic;
CREATE TABLE Traffic
(
id_user NUMBER(10) NOT NULL,
dat DATE NOT NULL,
amt NUMBER(20)
);

TRUNCATE TABLE Traffic;
TRUNCATE TABLE Tariff;
--user 1 (fair)   +
INSERT INTO traffic VALUES(1, to_date('01/01/2000', 'dd/mm/yyyy'), 100);
INSERT INTO traffic VALUES(1, to_date('01/02/2000', 'dd/mm/yyyy'), 600);
--user 2 (unfair) -
INSERT INTO tariff VALUES (2, to_date('01/01/2000', 'dd/mm/yyyy'), 1000);
INSERT INTO traffic VALUES(2, to_date('01/02/2000 16:00', 'dd/mm/yyyy HH24:MI'), 200);
INSERT INTO traffic VALUES(2, to_date('01/02/2000 16:02', 'dd/mm/yyyy HH24:MI'), 600);
INSERT INTO traffic VALUES(2, to_date('01/03/2000', 'dd/mm/yyyy'), 300);
--user 3 (fair)   +
INSERT INTO tariff VALUES (3, to_date('01/01/2000', 'dd/mm/yyyy'), 1000);
INSERT INTO traffic VALUES(3, to_date('01/02/2000', 'dd/mm/yyyy'), 200);
INSERT INTO traffic VALUES(3, to_date('01/06/2000', 'dd/mm/yyyy'), 200);
--user 4 (unfair) -
INSERT INTO tariff VALUES (4, to_date('01/01/2000', 'dd/mm/yyyy'), 1000);
INSERT INTO traffic VALUES(4, to_date('01/02/2000', 'dd/mm/yyyy'), 900);
INSERT INTO traffic VALUES(4, to_date('01/03/2000', 'dd/mm/yyyy'), 500);
INSERT INTO tariff VALUES (4, to_date('01/04/2000', 'dd/mm/yyyy'), 10000);
--user 5 (fair)   +
INSERT INTO tariff VALUES (5, to_date('01/01/2000', 'dd/mm/yyyy'), 1000);
INSERT INTO traffic VALUES(5, to_date('01/05/2000', 'dd/mm/yyyy'), 500);
INSERT INTO traffic VALUES(5, to_date('01/05/2001', 'dd/mm/yyyy'), 600);
--user 6 (unfair) -
INSERT INTO tariff VALUES (6, to_date('01/01/2000', 'dd/mm/yyyy'), 1000);
INSERT INTO traffic VALUES(6, to_date('01/02/2000', 'dd/mm/yyyy'), 900);
INSERT INTO traffic VALUES(6, to_date('01/04/2000', 'dd/mm/yyyy'), 50);
INSERT INTO tariff VALUES (6, to_date('01/05/2000', 'dd/mm/yyyy'), 900);
--user 7 (fair)   +
INSERT INTO traffic VALUES(7, to_date('01/01/2000', 'dd/mm/yyyy'), 2000);
INSERT INTO tariff VALUES (7, to_date('01/01/2001', 'dd/mm/yyyy'), 1000);
--user 8 (fair)   +
INSERT INTO tariff VALUES(8, to_date('01/01/2000', 'dd/mm/yyyy'), 2000);


-- для view:
CREATE OR REPLACE VIEW list_ AS
SELECT row_number() OVER(PARTITION BY id_user ORDER BY dat) num_, t.*
FROM (
      SELECT id_user, 'Тариф' type_, lim count_, tar_dat dat
      FROM Tariff
      UNION
      SELECT id_user, 'Трафик' type_, count_, dat
      FROM (
           SELECT id_user, sum(amt) count_, trunc(dat) dat
           FROM Traffic
           GROUP BY id_user, trunc(dat)
           ) tt
      UNION
      SELECT id_user, 'Тариф' type_, (999999) count_, to_date('01/01/1000', 'dd/mm/yyyy') dat -- 99..99 -непреодолимый лимит; 1000 год меньший любого возможного
      FROM (SELECT id_user FROM traffic) tt
     ) t;
------Вывод юзеров:
WITH t_list AS
(SELECT id_user, count_, dat
FROM list_ l WHERE type_ = 'Тариф'
ORDER BY id_user, dat DESC)
SELECT id_user, type_, dat, sum_before_100, limit_before_100, CASE WHEN sum_before_100 <= limit_before_100 THEN '+' ELSE 'CAUGTH' END AS check1,
       sum_after_100, limit_after_100, CASE WHEN sum_after_100 <= limit_after_100 THEN '+' ELSE 'CAUGTH' END AS check2
FROM( SELECT l.*,
           SUM(CASE type_ WHEN 'Трафик' THEN count_ ELSE 0 END)
           OVER(PARTITION BY id_user ORDER BY dat  RANGE 100 PRECEDING) sum_before_100,
           (SELECT count_ FROM t_list t WHERE t.id_user = l.id_user AND t.dat <= l.dat AND ROWNUM = 1) limit_before_100,
           COALESCE(SUM(CASE type_ WHEN 'Трафик' THEN count_ ELSE 0 END)
           OVER(PARTITION BY id_user ORDER BY dat RANGE BETWEEN 1 FOLLOWING AND 101 FOLLOWING), 0) sum_after_100,
           (SELECT count_ FROM t_list t WHERE t.id_user = l.id_user AND t.dat <= l.dat + 100 AND ROWNUM = 1) limit_after_100
     FROM list_ l) temp
ORDER BY id_user, num_;


------------------------------------------------------------------------------------------------------------------------------------------
                     -------------------------Период привязанный к тарифу.-----------------------
------------------------------------------------------------------------------------------------------------------------------------------
DROP TABLE Tar;
CREATE TABLE Tar
(
id_user NUMBER(10) NOT NULL,
tar_dat DATE NOT NULL,
lim NUMBER(20) CHECK(lim >= 0),
interval_ NUMBER(7),
PRIMARY KEY(id_user, tar_dat)
);

DROP TABLE Traf;
CREATE TABLE Traf
(
id_user NUMBER(10) NOT NULL,
dat DATE NOT NULL,
amt NUMBER(20)
);

TRUNCATE TABLE Traf;
TRUNCATE TABLE Tar;
--user 1 (fair)   +
INSERT INTO traf VALUES(1, to_date('01/01/2000', 'dd/mm/yyyy'), 1200);
INSERT INTO traf VALUES(1, to_date('01/03/2000', 'dd/mm/yyyy'), 1800);
--user 2 (unfair) -
INSERT INTO traf VALUES(2, to_date('01/05/2000', 'dd/mm/yyyy'), 1000);
INSERT INTO tar VALUES (2, to_date('01/06/2000', 'dd/mm/yyyy'), 2500, 50);
INSERT INTO traf VALUES(2, to_date('01/07/2000', 'dd/mm/yyyy'), 2000);
--user 3 (fair)   +
INSERT INTO traf VALUES(3, to_date('01/02/2000', 'dd/mm/yyyy'), 6000);
INSERT INTO tar VALUES (3, to_date('01/05/2000', 'dd/mm/yyyy'), 10000, 300);
INSERT INTO traf VALUES(3, to_date('01/08/2000', 'dd/mm/yyyy'), 3000);
--user 4 (unfair)   -
INSERT INTO traf VALUES(4, to_date('01/01/1999', 'dd/mm/yyyy'), 3000);
INSERT INTO tar VALUES (4, to_date('01/06/2000', 'dd/mm/yyyy'), 1500, 100);
INSERT INTO traf VALUES(4, to_date('01/01/2002', 'dd/mm/yyyy'), 8000);
--user 5 (unfair) -
INSERT INTO tar VALUES (5, to_date('01/01/2000', 'dd/mm/yyyy'), 1000, 50);
INSERT INTO traf VALUES(5, to_date('01/02/2000', 'dd/mm/yyyy'), 800);
INSERT INTO tar VALUES (5, to_date('01/04/2000', 'dd/mm/yyyy'), 9000, 10);
INSERT INTO traf VALUES(5, to_date('01/09/2000', 'dd/mm/yyyy'), 400);
INSERT INTO tar VALUES (5, to_date('01/11/2000', 'dd/mm/yyyy'), 2000, 500);
INSERT INTO traf VALUES(5, to_date('01/01/2001', 'dd/mm/yyyy'), 900);
--user 6 (unfair) -
INSERT INTO tar VALUES (6, to_date('01/01/2000', 'dd/mm/yyyy'), 500, 100);
INSERT INTO traf VALUES(6, to_date('01/01/2010', 'dd/mm/yyyy'), 1000);
INSERT INTO tar VALUES (6, to_date('01/01/2015', 'dd/mm/yyyy'), 20, 100);
INSERT INTO traf VALUES(6, to_date('01/01/2016', 'dd/mm/yyyy'), 10);

--work
CREATE OR REPLACE VIEW check_view AS
WITH tar_w AS
(SELECT * FROM tar ORDER BY tar_dat)
SELECT temp.*, CASE wHEN sum_ > lim THEN 'Попался' ELSE '+' END check_
FROM (SELECT t.id_user, t.tar_dat, t.interval_, t.lim,
             SUM(amt) OVER(PARTITION BY t.id_user, t.tar_dat ORDER BY f.dat) sum_, f.amt,  f.dat
      FROM tar t, (SELECT id_user, TRUNC(dat) dat, sum(amt) amt
                   FROM traf
                   GROUP BY id_user, TRUNC(dat)) f
      WHERE t.id_user = f.id_user AND ((f.dat >= t.tar_dat - t.interval_) AND
                                       (f.dat <= t.tar_dat + t.interval_
                                                OR t.tar_dat = (SELECT MAX(tar_dat) FROM traf tt
                                                                WHERE tt.id_user = t.id_user)
                                                OR f.dat < (SELECT tt.tar_dat - tt.interval_ FROM tar_w tt
                                                            WHERE tt.id_user = t.id_user AND t.tar_dat > tt.tar_dat AND ROWNUM = 1) ))
      ) temp
ORDER BY id_user, tar_dat;

--beatiful out
SELECT * FROM check_view
UNION ALL
SELECT null, null, null, null, null, null, null,
       'Нарушители: '||listagg(id_user, ', ') WITHIN GROUP(ORDER BY id_user)
       FROM (SELECT DISTINCT id_user
             FROM check_view
             WHERE check_ = 'Попался') t;
