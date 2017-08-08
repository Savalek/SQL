------------------------------------------------------------------------------------------------------------------------------------------
                          ------------------------- Глава 5_2. Аналитические функции. -----------------------
                          -------------------------------- Таблица "Счета" ----------------------------------
------------------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE tb (
act CHAR(1) NOT NULL,
dt DATE NOT NULL,
amt INTEGER NOT NULL);

TRUNCATE TABLE tb;
INSERT INTO tb VALUES('A', to_date('01/01/2000','dd/mm/yyyy'), 1000);
INSERT INTO tb VALUES('A', to_date('02/01/2000','dd/mm/yyyy'), 2000);
INSERT INTO tb VALUES('A', to_date('03/01/2000','dd/mm/yyyy'), 3000);
INSERT INTO tb VALUES('A', to_date('11/01/2000','dd/mm/yyyy'), 9999);
INSERT INTO tb VALUES('B', to_date('01/02/2000','dd/mm/yyyy'), 2000);
INSERT INTO tb VALUES('B', to_date('02/02/2000','dd/mm/yyyy'), 3000);
INSERT INTO tb VALUES('B', to_date('11/02/2000','dd/mm/yyyy'), 9999);
INSERT INTO tb VALUES('C', to_date('01/03/2000','dd/mm/yyyy'), 1000);
INSERT INTO tb VALUES('C', to_date('02/03/2000','dd/mm/yyyy'), 2000);
INSERT INTO tb VALUES('C', to_date('03/03/2000','dd/mm/yyyy'), 3000);
INSERT INTO tb VALUES('C', to_date('11/03/2000','dd/mm/yyyy'), 9999);

SELECT * FROM tb;

--1
SELECT act, amt 
FROM (
      SELECT t.*, CUME_DIST() OVER(PARTITION BY act ORDER BY dt) cum
      FROM tb t
     ) temp
WHERE cum = 1;

--2
SELECT act, amt 
FROM (
      SELECT t.*, DENSE_RANK() OVER(PARTITION BY act ORDER BY dt DESC) drank
      FROM tb t
     ) temp
WHERE drank = 1;

--3
SELECT act, amt 
FROM (
      SELECT t.*, RANK() OVER(PARTITION BY act ORDER BY dt DESC) drank
      FROM tb t
     ) temp
WHERE drank = 1;

--4
SELECT act, amt 
FROM (
      SELECT t.*, first_value(dt) OVER(PARTITION BY act ORDER BY dt DESC) fir_val
      FROM tb t
     ) temp
WHERE fir_val = dt;
--5
SELECT act, amt 
FROM (
      SELECT t.*, last_value(dt) OVER(PARTITION BY act) last_val
      FROM tb t
     ) temp
WHERE last_val = dt;
--6
SELECT act, amt 
FROM (
      SELECT t.*, LAG(dt, 1) OVER(PARTITION BY act ORDER BY dt DESC) lag_dt
      FROM tb t
     ) temp
WHERE lag_dt IS NULL;
--7
SELECT act, amt 
FROM (
      SELECT t.*, LEAD(dt, 1) OVER(PARTITION BY act ORDER BY dt) lead_dt
      FROM tb t
     ) temp
WHERE lead_dt IS NULL;
--8
SELECT act, amt 
FROM (
      SELECT t.*, MAX(dt) OVER(PARTITION BY act) max_dt
      FROM tb t
     ) temp
WHERE max_dt = dt;
--9
SELECT act, amt 
FROM (
      SELECT t.*, MIN(0 - (EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366)) 
                  OVER(PARTITION BY act ORDER BY dt) min_coff
      FROM tb t
     ) temp
WHERE min_coff = (
                  SELECT MIN(min_coff)
                  FROM (
                        SELECT t.*, MIN(0 - (EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366))
                                    OVER(PARTITION BY act ORDER BY dt) min_coff
                        FROM tb t
                        ) temp2
                  WHERE temp2.act = temp.act
                 );
--10----------------------------(завершена)
SELECT act, amt
FROM (
      SELECT t.*, NTILE(5) OVER(PARTITION BY act ORDER BY dt DESC) ntl
      FROM tb t 
     ) temp
WHERE ntl = 1;
--11
SELECT act, amt 
FROM (
      SELECT t.*, PERCENT_RANK() OVER(PARTITION BY act ORDER BY dt) pr
      FROM tb t
     ) temp
WHERE pr = 1;
--12
SELECT act, amt 
FROM (SELECT temp2.*,MAX(r_to_r) OVER(PARTITION BY act) r_to_r_max
      FROM (
            SELECT t.*, RATIO_TO_REPORT(EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366)
                        OVER(PARTITION BY act) r_to_r
            FROM tb t
            ) temp2
     ) temp
WHERE r_to_r = r_to_r_max;
--13
SELECT act, amt 
FROM (
      SELECT t.*, ROW_NUMBER() OVER(PARTITION BY act ORDER BY dt DESC) numb
      FROM tb t
     ) temp
WHERE numb = 1;
--14
SELECT act, amt 
FROM (
      SELECT t.*, VAR_SAMP(EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366) OVER(PARTITION BY act ORDER BY dt DESC) stmp
      FROM tb t
     ) temp
WHERE stmp IS NULL;

--15
SELECT act, amt 
FROM (
      SELECT t.*, VARIANCE(EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366) OVER(PARTITION BY act ORDER BY dt DESC) stmp
      FROM tb t
     ) temp
WHERE stmp = 0;
--16
SELECT act, amt 
FROM (
      SELECT t.*, VAR_POP(EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366) OVER(PARTITION BY act ORDER BY dt DESC) stmp
      FROM tb t
     ) temp
WHERE stmp = 0;
--17
SELECT act, amt 
FROM (
      SELECT t.*, SUM(EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366) OVER(PARTITION BY act ORDER BY dt) sm
      FROM tb t
     ) temp
WHERE sm = (
           SELECT MAX(sm)
           FROM (
                SELECT t.*, SUM(EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366) OVER(PARTITION BY act ORDER BY dt) sm
                FROM tb t
                ) temp2
           WHERE temp.act = temp2.act
           );
--18
SELECT act, amt 
FROM (
      SELECT t.*, STDDEV_SAMP(EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366) OVER(PARTITION BY act ORDER BY dt DESC) stmp
      FROM tb t
     ) temp
WHERE stmp IS NULL;
--19
SELECT act, amt 
FROM (
      SELECT t.*, STDDEV_POP(EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366) OVER(PARTITION BY act ORDER BY dt DESC) stmp
      FROM tb t
     ) temp
WHERE stmp = 0;
--20
SELECT act, amt 
FROM (
      SELECT t.*, STDDEV(EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366) OVER(PARTITION BY act ORDER BY dt DESC) stmp
      FROM tb t
     ) temp
WHERE stmp = 0;
--21
SELECT act, amt 
FROM (
      SELECT t.*, REGR_SLOPE(1,EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366) OVER(PARTITION BY act ORDER BY dt DESC) stmp
      FROM tb t
     ) temp
WHERE stmp IS NULL;
--22
SELECT act, amt 
FROM (
      SELECT t.*, REGR_INTERCEPT(1,EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366) OVER(PARTITION BY act ORDER BY dt DESC) stmp
      FROM tb t
     ) temp
WHERE stmp IS NULL;
--23
SELECT act, amt 
FROM (
      SELECT t.*, REGR_R2(1,EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366) OVER(PARTITION BY act ORDER BY dt DESC) stmp
      FROM tb t
     ) temp
WHERE stmp IS NULL;
--24
SELECT act, amt 
FROM (
      SELECT t.*, REGR_COUNT(1,EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366) OVER(PARTITION BY act ORDER BY dt DESC) stmp
      FROM tb t
     ) temp
WHERE stmp IS NULL;
--25------------(MAX)
SELECT act, amt 
FROM (
      SELECT t.*, REGR_AVGX(1,EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366) OVER(PARTITION BY act ORDER BY dt DESC) stmp
      FROM tb t
     ) temp
WHERE stmp = (
              SELECT MAX(stmp)
              FROM (
                    SELECT t.*, REGR_AVGX(1,EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366) OVER(PARTITION BY act ORDER BY dt DESC) stmp
                    FROM tb t
                    ) temp2
              WHERE temp.act = temp2.act
             );
--26
SELECT act, amt 
FROM (
      SELECT t.*, REGR_AVGY(EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366, 1) OVER(PARTITION BY act ORDER BY dt DESC) stmp
      FROM tb t
     ) temp
WHERE stmp = (
              SELECT MAX(stmp)
              FROM (
                    SELECT t.*, REGR_AVGY(EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366, 1) OVER(PARTITION BY act ORDER BY dt DESC) stmp
                    FROM tb t
                    ) temp2
              WHERE temp.act = temp2.act
             );
--27
SELECT act, amt 
FROM (
      SELECT t.*, REGR_SXY(SYSDATE - dt, amt) OVER(PARTITION BY act ORDER BY dt DESC) stmp
      FROM tb t
     ) temp
WHERE stmp = 0;
--28
SELECT act, amt 
FROM (
      SELECT t.*, REGR_SXX(SYSDATE - dt, amt) OVER(PARTITION BY act ORDER BY dt DESC) stmp
      FROM tb t
     ) temp
WHERE stmp = 0;
--29
SELECT act, amt 
FROM (
      SELECT t.*, REGR_SYY(SYSDATE - dt, amt) OVER(PARTITION BY act ORDER BY dt DESC) stmp
      FROM tb t
     ) temp
WHERE stmp = 0;
--30
SELECT act, amt 
FROM (
      SELECT t.*, CORR(SYSDATE - dt, amt) OVER(PARTITION BY act ORDER BY dt DESC) stmp
      FROM tb t
     ) temp
WHERE stmp IS NULL;
--31
SELECT act, amt 
FROM (
      SELECT t.*, PERCENTILE_CONT(1) WITHIN GROUP (ORDER BY dt) OVER(PARTITION BY act) stmp
      FROM tb t
     ) temp
WHERE stmp = dt;
--32
SELECT act, amt 
FROM (
      SELECT t.*, PERCENTILE_DISC(1) WITHIN GROUP (ORDER BY dt) OVER(PARTITION BY act) stmp
      FROM tb t
     ) temp
WHERE stmp = dt;
--33
SELECT act, amt 
FROM (
      SELECT t.*, AVG(EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366) OVER(PARTITION BY act ORDER BY dt) stmp
      FROM tb t
     ) temp
WHERE stmp = (
              SELECT MAX(stmp)
              FROM (
                   SELECT t.*, AVG(EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366) OVER(PARTITION BY act ORDER BY dt) stmp
                   FROM tb t
                   ) t
              WHERE t.act = temp.act
             );
--------------------------------view
CREATE OR REPLACE VIEW tbv AS
SELECT tb.*, ASCII(act) ind
FROM tb;
--------34
SELECT act, amt 
FROM (
      SELECT t.*, CUME_DIST() OVER(ORDER BY ind, dt) cum
      FROM tbv t
     ) temp
WHERE cum = (
            SELECT MAX(cum)
            FROM (
                  SELECT t.*, CUME_DIST() OVER(ORDER BY ind, dt) cum
                  FROM tbv t
                 ) tt
            WHERE tt.act = temp.act
            );

--35
SELECT act, amt 
FROM (
      SELECT t.*, first_value(dt) OVER(PARTITION BY act ORDER BY dt DESC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) fir_val
      FROM tb t
     ) temp
WHERE fir_val = dt;
--36
SELECT act, amt 
FROM (
      SELECT t.*, MAX(dt) OVER(PARTITION BY act ORDER BY dt DESC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) max_dt
      FROM tb t
     ) temp
WHERE max_dt = dt;
--37
SELECT act, amt 
FROM (
      SELECT t.*, SUM(EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366) OVER(PARTITION BY act  ORDER BY dt DESC ROWS BETWEEN UNBOUNDED PRECEDING AND 0 FOLLOWING) sm
      FROM tb t
     ) temp
WHERE sm = (
           SELECT MIN(sm)
           FROM (
                SELECT t.*, SUM(EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366) OVER(PARTITION BY act  ORDER BY dt DESC ROWS BETWEEN UNBOUNDED PRECEDING AND 0 FOLLOWING) sm
                FROM tb t
                ) temp2
           WHERE temp.act = temp2.act
           );
--38
SELECT act, amt 
FROM (
      SELECT t.*, STDDEV_SAMP(EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366) OVER(PARTITION BY act  ORDER BY dt DESC ROWS BETWEEN UNBOUNDED PRECEDING AND 0 FOLLOWING) stmp
      FROM tb t
     ) temp
WHERE stmp IS NULL;
--39
SELECT act, amt 
FROM (
      SELECT t.*, STDDEV_POP(EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366) OVER(PARTITION BY act  ORDER BY dt DESC ROWS BETWEEN UNBOUNDED PRECEDING AND 0 FOLLOWING) stmp
      FROM tb t
     ) temp
WHERE stmp = 0; 
--40
SELECT act, amt 
FROM (
      SELECT t.*, STDDEV(EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366) OVER(PARTITION BY act  ORDER BY dt DESC ROWS BETWEEN UNBOUNDED PRECEDING AND 0 FOLLOWING) stmp
      FROM tb t
     ) temp
WHERE stmp = 0;
--41
SELECT act, amt 
FROM (
      SELECT t.*, REGR_SLOPE(1,EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366) OVER(PARTITION BY act  ORDER BY dt DESC ROWS BETWEEN UNBOUNDED PRECEDING AND 0 FOLLOWING) stmp
      FROM tb t
     ) temp
WHERE stmp IS NULL;
--42
SELECT act, amt 
FROM (
      SELECT t.*, REGR_INTERCEPT(1,EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366) OVER(PARTITION BY act  ORDER BY dt DESC ROWS BETWEEN UNBOUNDED PRECEDING AND 0 FOLLOWING) stmp
      FROM tb t
     ) temp
WHERE stmp IS NULL;
--43
SELECT act, amt 
FROM (
      SELECT t.*, REGR_R2(1,EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366) OVER(PARTITION BY act ORDER BY dt DESC ROWS BETWEEN UNBOUNDED PRECEDING AND 0 FOLLOWING) stmp
      FROM tb t
     ) temp
WHERE stmp IS NULL;
--44
SELECT act, amt 
FROM (
      SELECT t.*, REGR_COUNT(1,EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366) OVER(PARTITION BY act  ORDER BY dt DESC ROWS BETWEEN UNBOUNDED PRECEDING AND 0 FOLLOWING) stmp
      FROM tb t
     ) temp
WHERE stmp IS NULL;
--45
SELECT act, amt 
FROM (
      SELECT t.*, REGR_AVGX(1,EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366) OVER(PARTITION BY act  ORDER BY dt DESC ROWS BETWEEN UNBOUNDED PRECEDING AND 0 FOLLOWING) stmp
      FROM tb t
     ) temp
WHERE stmp = (
              SELECT MAX(stmp)
              FROM (
                    SELECT t.*, REGR_AVGX(1,EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366) OVER(PARTITION BY act  ORDER BY dt DESC ROWS BETWEEN UNBOUNDED PRECEDING AND 0 FOLLOWING) stmp
                    FROM tb t
                    ) temp2
              WHERE temp.act = temp2.act
             );
--46
SELECT act, amt 
FROM (
      SELECT t.*, REGR_AVGY(EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366, 1) OVER(PARTITION BY act  ORDER BY dt DESC ROWS BETWEEN UNBOUNDED PRECEDING AND 0 FOLLOWING) stmp
      FROM tb t
     ) temp
WHERE stmp = (
              SELECT MAX(stmp)
              FROM (
                    SELECT t.*, REGR_AVGY(EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366, 1) OVER(PARTITION BY act  ORDER BY dt DESC ROWS BETWEEN UNBOUNDED PRECEDING AND 0 FOLLOWING) stmp
                    FROM tb t
                    ) temp2
              WHERE temp.act = temp2.act
             );
--47
SELECT act, amt 
FROM (
      SELECT t.*, REGR_SXY(SYSDATE - dt, amt) OVER(PARTITION BY act  ORDER BY dt DESC ROWS BETWEEN UNBOUNDED PRECEDING AND 0 FOLLOWING) stmp
      FROM tb t
     ) temp
WHERE stmp = 0;
--48
SELECT act, amt 
FROM (
      SELECT t.*, REGR_SXX(SYSDATE - dt, amt) OVER(PARTITION BY act  ORDER BY dt DESC ROWS BETWEEN UNBOUNDED PRECEDING AND 0 FOLLOWING) stmp
      FROM tb t
     ) temp
WHERE stmp = 0;
--49
SELECT act, amt 
FROM (
      SELECT t.*, REGR_SYY(SYSDATE - dt, amt) OVER(PARTITION BY act  ORDER BY dt DESC ROWS BETWEEN UNBOUNDED PRECEDING AND 0 FOLLOWING) stmp
      FROM tb t
     ) temp
WHERE stmp = 0;
--50
SELECT act, amt 
FROM (
      SELECT t.*, CORR(SYSDATE - dt, amt) OVER(PARTITION BY act ORDER BY dt DESC ROWS BETWEEN UNBOUNDED PRECEDING AND 0 FOLLOWING) stmp
      FROM tb t
     ) temp
WHERE stmp IS NULL;
--51
SELECT act, amt 
FROM (
      SELECT t.*, AVG(EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366) OVER(PARTITION BY act  ORDER BY dt DESC ROWS BETWEEN UNBOUNDED PRECEDING AND 0 FOLLOWING) stmp
      FROM tb t
     ) temp
WHERE stmp = (
              SELECT MAX(stmp)
              FROM (
                   SELECT t.*, AVG(EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366) OVER(PARTITION BY act  ORDER BY dt DESC ROWS BETWEEN UNBOUNDED PRECEDING AND 0 FOLLOWING) stmp
                   FROM tb t
                   ) t
              WHERE t.act = temp.act
             );
--52
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt IN (
             SELECT MAX(dt)
             FROM tb
             WHERE t.act = act
            );
--53
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt IN (
             SELECT dt 
             FROM (
             SELECT t.*, CUME_DIST() OVER(PARTITION BY act ORDER BY dt) cum
             FROM tb t
             ) temp
             WHERE cum = 1
             AND t.act = act
            );
--54
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt IN (
             SELECT dt 
             FROM 
             (
             SELECT t.*, DENSE_RANK() OVER(PARTITION BY act ORDER BY dt DESC) drank
             FROM tb t
             ) temp
             WHERE drank = 1
             AND t.act = act
            );
--55
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt IN (
             SELECT dt 
             FROM 
             (
             SELECT t.*, RANK() OVER(PARTITION BY act ORDER BY dt DESC) drank
             FROM tb t
             ) temp
             WHERE drank = 1
             AND t.act = act
            );
--56
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt IN (
             SELECT dt 
             FROM 
             (
             SELECT t.*, first_value(dt) OVER(PARTITION BY act ORDER BY dt DESC) fir_val
             FROM tb t
             ) temp
             WHERE fir_val = dt
             AND t.act = act
            );
--57
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt IN (
             SELECT dt 
             FROM 
             (
             SELECT t.*, last_value(dt) OVER(PARTITION BY act) last_val
             FROM tb t
             ) temp
             WHERE last_val = dt
             AND t.act = act
            );
--58
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt IN (
             SELECT dt 
             FROM 
             (
             SELECT t.*, LAG(dt, 1) OVER(PARTITION BY act ORDER BY dt DESC) lag_dt
             FROM tb t
             ) temp
             WHERE lag_dt IS NULL
             AND t.act = act
            );
--59
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt IN (
             SELECT dt 
             FROM 
             (
             SELECT t.*, LEAD(dt, 1) OVER(PARTITION BY act ORDER BY dt) lead_dt
             FROM tb t
             ) temp
             WHERE lead_dt IS NULL
             AND t.act = act
            );
--60
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt IN (
             SELECT dt 
             FROM 
             (
             SELECT t.*, MAX(dt) OVER(PARTITION BY act) max_dt
             FROM tb t
             ) temp
             WHERE max_dt = dt
             AND t.act = act
            );
--61
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt IN (
             SELECT dt 
             FROM (
             SELECT t.*, MIN(0 - (EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366)) 
                  OVER(PARTITION BY act ORDER BY dt) min_coff
                   FROM tb t
                     ) temp
                     WHERE min_coff = (
                  SELECT MIN(min_coff)
                  FROM (
                        SELECT t.*, MIN(0 - (EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366))
                                    OVER(PARTITION BY act ORDER BY dt) min_coff
                        FROM tb t
                        ) temp2
                  WHERE temp2.act = temp.act
                 ));
--62
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt IN (
             SELECT dt 
             FROM 
             (
             SELECT t.*, PERCENT_RANK() OVER(PARTITION BY act ORDER BY dt) pr
             FROM tb t
              ) temp
              WHERE pr = 1
             AND t.act = act
            );
--63
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt IN (
             SELECT dt 
             FROM (SELECT temp2.*,MAX(r_to_r) OVER(PARTITION BY act) r_to_r_max
             FROM (
            SELECT t.*, RATIO_TO_REPORT(EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366)
                        OVER(PARTITION BY act) r_to_r
            FROM tb t
            ) temp2
             ) temp
             WHERE r_to_r = r_to_r_max
             AND t.act = act
            );
--64
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt IN (
             SELECT dt 
             FROM 
             (
             SELECT t.*, ROW_NUMBER() OVER(PARTITION BY act ORDER BY dt DESC) numb
             FROM tb t
             ) temp
             WHERE numb = 1
             AND t.act = act
            );
--65
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt IN (
             SELECT dt 
             FROM 
             (
             SELECT t.*, VAR_SAMP(EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366) OVER(PARTITION BY act ORDER BY dt DESC) stmp
              FROM tb t
              ) temp
              WHERE stmp IS NULL
             AND t.act = act
            );
--66
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt IN (
             SELECT dt 
             FROM 
             (
              SELECT t.*, VARIANCE(EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366) OVER(PARTITION BY act ORDER BY dt DESC) stmp
              FROM tb t
              ) temp
              WHERE stmp = 0
             AND t.act = act
            );
--67
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt IN (
             SELECT dt 
             FROM 
             (
              SELECT t.*, VAR_POP(EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366) OVER(PARTITION BY act ORDER BY dt DESC) stmp
              FROM tb t
              ) temp
              WHERE stmp = 0
             AND t.act = act
            );
--68
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt IN (
             SELECT dt 
             FROM (
      SELECT t.*, SUM(EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366) OVER(PARTITION BY act ORDER BY dt) sm
      FROM tb t
     ) temp
     WHERE sm = (
           SELECT MAX(sm)
           FROM (
                SELECT t.*, SUM(EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366) OVER(PARTITION BY act ORDER BY dt) sm
                FROM tb t
                ) temp2
           WHERE temp.act = temp2.act
           )
             AND t.act = act
            );
--69
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt IN (
             SELECT dt 
             FROM 
             (
              SELECT t.*, STDDEV_SAMP(EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366) OVER(PARTITION BY act ORDER BY dt DESC) stmp
              FROM tb t
              ) temp
              WHERE stmp IS NULL
             AND t.act = act
            );
--70
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt IN (
             SELECT dt 
             FROM 
             (
             SELECT t.*, STDDEV_POP(EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366) OVER(PARTITION BY act ORDER BY dt DESC) stmp
             FROM tb t
             ) temp
             WHERE stmp = 0
             AND t.act = act
            );
--71
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt IN (
             SELECT dt 
             FROM 
             (
             SELECT t.*, STDDEV(EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366) OVER(PARTITION BY act ORDER BY dt DESC) stmp
             FROM tb t
             ) temp
             WHERE stmp = 0
             AND t.act = act
            );
--72
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt IN (
             SELECT dt 
             FROM 
             (
             SELECT t.*, REGR_SLOPE(1,EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366) OVER(PARTITION BY act ORDER BY dt DESC) stmp
             FROM tb t
             ) temp
             WHERE stmp IS NULL
             AND t.act = act
            );
--73
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt IN (
             SELECT dt 
             FROM 
             (
             SELECT t.*, REGR_INTERCEPT(1,EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366) OVER(PARTITION BY act ORDER BY dt DESC) stmp
             FROM tb t
             ) temp
             WHERE stmp IS NULL
             AND t.act = act
            );
--74
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt IN (
             SELECT dt 
             FROM 
             (
            SELECT t.*, REGR_R2(1,EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366) OVER(PARTITION BY act ORDER BY dt DESC) stmp
            FROM tb t
            ) temp
            WHERE stmp IS NULL
             AND t.act = act
            );
--75
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt IN (
             SELECT dt 
             FROM (
             SELECT t.*, REGR_AVGX(1,EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366) OVER(PARTITION BY act ORDER BY dt DESC) stmp
             FROM tb t
             	) temp
              WHERE stmp = (
              SELECT MAX(stmp)
              FROM (
                    SELECT t.*, REGR_AVGX(1,EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366) OVER(PARTITION BY act ORDER BY dt DESC) stmp
                    FROM tb t
                    ) temp2
              WHERE temp.act = temp2.act
             )
             AND t.act = act
            );
--76
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt IN (
             SELECT dt 
             FROM (
             SELECT t.*, REGR_AVGY(EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366, 1) OVER(PARTITION BY act ORDER BY dt DESC) stmp
             FROM tb t
             ) temp
             WHERE stmp = (
              SELECT MAX(stmp)
              FROM (
                    SELECT t.*, REGR_AVGY(EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366, 1) OVER(PARTITION BY act ORDER BY dt DESC) stmp
                    FROM tb t
                    ) temp2
              WHERE temp.act = temp2.act
             )
             AND t.act = act
            );
--77
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt IN (
             SELECT dt 
             FROM 
             (
            SELECT t.*, REGR_SXY(SYSDATE - dt, amt) OVER(PARTITION BY act ORDER BY dt DESC) stmp
            FROM tb t
            ) temp
            WHERE stmp = 0
             AND t.act = act
            );
--78
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt IN (
             SELECT dt 
             FROM 
             (
            SELECT t.*, REGR_SXX(SYSDATE - dt, amt) OVER(PARTITION BY act ORDER BY dt DESC) stmp
            FROM tb t
            ) temp
            WHERE stmp = 0
             AND t.act = act
            );
--79
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt IN (
             SELECT dt 
             FROM 
             (
           SELECT t.*, REGR_SYY(SYSDATE - dt, amt) OVER(PARTITION BY act ORDER BY dt DESC) stmp
           FROM tb t
           ) temp
           WHERE stmp = 0
             AND t.act = act
            );
--80
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt IN (
             SELECT dt 
             FROM 
             (
            SELECT t.*, CORR(SYSDATE - dt, amt) OVER(PARTITION BY act ORDER BY dt DESC) stmp
            FROM tb t
            ) temp
            WHERE stmp IS NULL
             AND t.act = act
            );
--81
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt IN (
             SELECT dt 
             FROM 
             (
            SELECT t.*, PERCENTILE_CONT(1) WITHIN GROUP (ORDER BY dt) OVER(PARTITION BY act) stmp
            FROM tb t
            ) temp
            WHERE stmp = dt
             AND t.act = act
            );
--82
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt IN (
             SELECT dt 
             FROM 
             (
            SELECT t.*, PERCENTILE_DISC(1) WITHIN GROUP (ORDER BY dt) OVER(PARTITION BY act) stmp
            FROM tb t
            ) temp
            WHERE stmp = dt
             AND t.act = act
            );
--83
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt IN (
             SELECT dt 
             FROM (
             SELECT t.*, AVG(EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366) OVER(PARTITION BY act ORDER BY dt) stmp
             FROM tb t
             ) temp
             WHERE stmp = (
              SELECT MAX(stmp)
              FROM (
                   SELECT t.*, AVG(EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366) OVER(PARTITION BY act ORDER BY dt) stmp
                   FROM tb t
                   ) t
              WHERE t.act = temp.act
             AND t.act = act
            ));
--84
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt IN (
             SELECT dt 
             FROM (
             SELECT t.*, CUME_DIST() OVER(ORDER BY ind, dt) cum
             FROM tbv t
             ) temp
             WHERE cum = (
            SELECT MAX(cum)
            FROM (
                  SELECT t.*, CUME_DIST() OVER(ORDER BY ind, dt) cum
                  FROM tbv t
                 ) tt
            WHERE tt.act = temp.act
             AND t.act = act
            ));
--85
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt IN (
             SELECT dt 
             FROM 
             (
            SELECT t.*, first_value(dt) OVER(PARTITION BY act ORDER BY dt DESC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) fir_val
            FROM tb t
            ) temp
            WHERE fir_val = dt
             AND t.act = act
            );
--86
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt IN (
             SELECT dt 
             FROM 
             (
            SELECT t.*, MAX(dt) OVER(PARTITION BY act ORDER BY dt DESC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) max_dt
            FROM tb t
            ) temp
            WHERE max_dt = dt
             AND t.act = act
            );
--87
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt IN (
             SELECT dt 
             FROM (
      SELECT t.*, SUM(EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366) OVER(PARTITION BY act  ORDER BY dt DESC ROWS BETWEEN UNBOUNDED PRECEDING AND 0 FOLLOWING) sm
      FROM tb t
     ) temp
     WHERE sm = (
           SELECT MIN(sm)
           FROM (
                SELECT t.*, SUM(EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366) OVER(PARTITION BY act  ORDER BY dt DESC ROWS BETWEEN UNBOUNDED PRECEDING AND 0 FOLLOWING) sm
                FROM tb t
                ) temp2
           WHERE temp.act = temp2.act
           
             AND t.act = act
            ));
--88
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt IN (
             SELECT dt 
             FROM 
             (
           SELECT t.*, STDDEV_SAMP(EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366) OVER(PARTITION BY act  ORDER BY dt DESC ROWS BETWEEN UNBOUNDED PRECEDING AND 0 FOLLOWING) stmp
           FROM tb t
           ) temp
           WHERE stmp IS NULL
             AND t.act = act
            );
--89
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt IN (
             SELECT dt 
             FROM 
             (
           SELECT t.*, STDDEV_POP(EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366) OVER(PARTITION BY act  ORDER BY dt DESC ROWS BETWEEN UNBOUNDED PRECEDING AND 0 FOLLOWING) stmp
           FROM tb t
           ) temp
           WHERE stmp = 0
             AND t.act = act
            );
--90
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt IN (
             SELECT dt 
             FROM 
             (
           SELECT t.*, STDDEV(EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366) OVER(PARTITION BY act  ORDER BY dt DESC ROWS BETWEEN UNBOUNDED PRECEDING AND 0 FOLLOWING) stmp
           FROM tb t
           ) temp
           WHERE stmp = 0
             AND t.act = act
            );
--91
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt IN (
             SELECT dt 
             FROM 
             (
           SELECT t.*, REGR_SLOPE(1,EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366) OVER(PARTITION BY act  ORDER BY dt DESC ROWS BETWEEN UNBOUNDED PRECEDING AND 0 FOLLOWING) stmp
           FROM tb t
           ) temp
           WHERE stmp IS NULL
             AND t.act = act
            );
--92
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt IN (
             SELECT dt 
             FROM 
             (
           SELECT t.*, REGR_INTERCEPT(1,EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366) OVER(PARTITION BY act  ORDER BY dt DESC ROWS BETWEEN UNBOUNDED PRECEDING AND 0 FOLLOWING) stmp
           FROM tb t
           ) temp
           WHERE stmp IS NULL
             AND t.act = act
            );
--93
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt IN (
             SELECT dt 
             FROM 
             (
           SELECT t.*, REGR_R2(1,EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366) OVER(PARTITION BY act ORDER BY dt DESC ROWS BETWEEN UNBOUNDED PRECEDING AND 0 FOLLOWING) stmp
           FROM tb t
           ) temp
           WHERE stmp IS NULL
             AND t.act = act
            );
--94
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt IN (
             SELECT dt 
             FROM (
             SELECT t.*, REGR_AVGX(1,EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366) OVER(PARTITION BY act  ORDER BY dt DESC ROWS BETWEEN UNBOUNDED PRECEDING AND 0 FOLLOWING) stmp
             FROM tb t
             ) temp
             WHERE stmp = (
              SELECT MAX(stmp)
              FROM (
                    SELECT t.*, REGR_AVGX(1,EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366) OVER(PARTITION BY act  ORDER BY dt DESC ROWS BETWEEN UNBOUNDED PRECEDING AND 0 FOLLOWING) stmp
                    FROM tb t
                    ) temp2
              WHERE temp.act = temp2.act
             AND t.act = act
            ));
--95
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt IN (
             SELECT dt 
             FROM (
             SELECT t.*, REGR_AVGY(EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366, 1) OVER(PARTITION BY act  ORDER BY dt DESC ROWS BETWEEN UNBOUNDED PRECEDING AND 0 FOLLOWING) stmp
             FROM tb t
             ) temp
             WHERE stmp = (
              SELECT MAX(stmp)
              FROM (
                    SELECT t.*, REGR_AVGY(EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366, 1) OVER(PARTITION BY act  ORDER BY dt DESC ROWS BETWEEN UNBOUNDED PRECEDING AND 0 FOLLOWING) stmp
                    FROM tb t
                    ) temp2
              WHERE temp.act = temp2.act
             AND t.act = act
            ));
--96
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt IN (
             SELECT dt 
             FROM 
             (
           SELECT t.*, REGR_SXY(SYSDATE - dt, amt) OVER(PARTITION BY act  ORDER BY dt DESC ROWS BETWEEN UNBOUNDED PRECEDING AND 0 FOLLOWING) stmp
           FROM tb t
           ) temp
           WHERE stmp = 0
             AND t.act = act
            );
--97
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt IN (
             SELECT dt 
             FROM 
             (
           SELECT t.*, REGR_SXX(SYSDATE - dt, amt) OVER(PARTITION BY act  ORDER BY dt DESC ROWS BETWEEN UNBOUNDED PRECEDING AND 0 FOLLOWING) stmp
           FROM tb t
           ) temp
           WHERE stmp = 0
             AND t.act = act
            );
--98
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt IN (
             SELECT dt 
             FROM 
             (
           SELECT t.*, REGR_SYY(SYSDATE - dt, amt) OVER(PARTITION BY act  ORDER BY dt DESC ROWS BETWEEN UNBOUNDED PRECEDING AND 0 FOLLOWING) stmp
           FROM tb t
           ) temp
           WHERE stmp = 0
             AND t.act = act
            );
--99
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt IN (
             SELECT dt 
             FROM 
             (
           SELECT t.*, CORR(SYSDATE - dt, amt) OVER(PARTITION BY act ORDER BY dt DESC ROWS BETWEEN UNBOUNDED PRECEDING AND 0 FOLLOWING) stmp
           FROM tb t
           ) temp
           WHERE stmp IS NULL
             AND t.act = act
            );
--100
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt IN (
             SELECT dt 
             FROM (
             SELECT t.*, AVG(EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366) OVER(PARTITION BY act  ORDER BY dt DESC ROWS BETWEEN UNBOUNDED PRECEDING AND 0 FOLLOWING) stmp
             FROM tb t
             ) temp
             WHERE stmp = (
              SELECT MAX(stmp)
              FROM (
                   SELECT t.*, AVG(EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366) OVER(PARTITION BY act  ORDER BY dt DESC ROWS BETWEEN UNBOUNDED PRECEDING AND 0 FOLLOWING) stmp
                   FROM tb t
                   ) t
              WHERE t.act = temp.act
             AND t.act = act
            ));
--101
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt IN (
             SELECT dt 
             FROM 
             (
           SELECT t.*, CORR(SYSDATE - dt, amt) OVER(PARTITION BY act ORDER BY dt DESC ROWS BETWEEN UNBOUNDED PRECEDING AND 0 FOLLOWING) stmp
           FROM tb t
           ) temp
           WHERE stmp IS NULL
             AND t.act = act
            );
--102
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt = (
            SELECT max(dt)
            FROM (
             SELECT t.*, STDDEV_SAMP(EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366) OVER(PARTITION BY act ORDER BY dt DESC) stmp
             FROM tb t
            ) temp
            WHERE t.act = act
            );
--103
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt = (
            SELECT max(dt)
            FROM 
            (
             SELECT t.*, STDDEV_POP(EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366) OVER(PARTITION BY act ORDER BY dt DESC) stmp
             FROM tb t
            ) temp
            WHERE t.act = act
            );
--104
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt = (
            SELECT max(dt)
            FROM 
            (
             SELECT t.*, STDDEV(EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366) OVER(PARTITION BY act ORDER BY dt DESC) stmp
             FROM tb t
            ) temp
            WHERE t.act = act
            );
--105
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt = (
            SELECT max(dt)
            FROM 
            (
              SELECT t.*, REGR_INTERCEPT(1,EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366) OVER(PARTITION BY act ORDER BY dt DESC) stmp
              FROM tb t
            ) temp
            WHERE t.act = act
            );
--106
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt = (
            SELECT max(dt)
            FROM 
            (
              SELECT t.*, REGR_R2(1,EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366) OVER(PARTITION BY act ORDER BY dt DESC) stmp
              FROM tb t
            ) temp
            WHERE t.act = act
            );
--107
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt = (
            SELECT max(dt)
            FROM 
            (
              SELECT t.*, REGR_COUNT(1,EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366) OVER(PARTITION BY act ORDER BY dt DESC) stmp
              FROM tb t
            ) temp
            WHERE t.act = act
            );
--108
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt = (
            SELECT max(dt)
            FROM 
            (
              SELECT t.*, REGR_AVGX(1,EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366) OVER(PARTITION BY act ORDER BY dt DESC) stmp
              FROM tb t
            ) temp
            WHERE t.act = act
            );
--109
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt = (
            SELECT max(dt)
            FROM 
            (
              SELECT t.*, REGR_AVGY(1,EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366) OVER(PARTITION BY act ORDER BY dt DESC) stmp
              FROM tb t
            ) temp
            WHERE t.act = act
            );
--110
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt = (
            SELECT max(dt)
            FROM 
            (
              SELECT t.*, REGR_AVGY(1,EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366) OVER(PARTITION BY act ORDER BY dt DESC) stmp
              FROM tb t
            ) temp
            WHERE t.act = act
            );
--111
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt = (
            SELECT max(dt)
            FROM 
            (
               SELECT t.*, REGR_SXY(SYSDATE - dt, amt) OVER(PARTITION BY act  ORDER BY dt DESC ROWS BETWEEN UNBOUNDED PRECEDING AND 0 FOLLOWING) stmp
               FROM tb t
            ) temp
            WHERE t.act = act
            );
--112
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt = (
            SELECT max(dt)
            FROM 
            (
                SELECT t.*, REGR_SXX(SYSDATE - dt, amt) OVER(PARTITION BY act  ORDER BY dt DESC ROWS BETWEEN UNBOUNDED PRECEDING AND 0 FOLLOWING) stmp
                FROM tb t
            ) temp
            WHERE t.act = act
            );
--113
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt = (
            SELECT max(dt)
            FROM 
            (
                SELECT t.*, REGR_SXX(SYSDATE - dt, amt) OVER(PARTITION BY act  ORDER BY dt DESC ROWS BETWEEN UNBOUNDED PRECEDING AND 0 FOLLOWING) stmp
                FROM tb t
            ) temp
            WHERE t.act = act
            );
--114
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt = (
            SELECT max(dt)
            FROM 
            (
                SELECT t.*, REGR_SYY(SYSDATE - dt, amt) OVER(PARTITION BY act  ORDER BY dt DESC ROWS BETWEEN UNBOUNDED PRECEDING AND 0 FOLLOWING) stmp
                FROM tb t
            ) temp
            WHERE t.act = act
            );
--115
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt = (
            SELECT max(dt)
            FROM 
            (
                SELECT t.*, CORR(SYSDATE - dt, amt) OVER(PARTITION BY act ORDER BY dt DESC ROWS BETWEEN UNBOUNDED PRECEDING AND 0 FOLLOWING) stmp
                FROM tb t
            ) temp
            WHERE t.act = act
            );
--116
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt = (
            SELECT max(dt)
            FROM 
            (
                SELECT t.*, AVG(EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366) OVER(PARTITION BY act  ORDER BY dt DESC ROWS BETWEEN UNBOUNDED PRECEDING AND 0 FOLLOWING) stmp
                FROM tb t
            ) temp
            WHERE t.act = act
            );
--117
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt = (
            SELECT max(dt)
            FROM 
            (
                SELECT t.*, AVG(EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366) OVER(PARTITION BY act  ORDER BY dt DESC ROWS BETWEEN UNBOUNDED PRECEDING AND 0 FOLLOWING) stmp
                FROM tb t
            ) temp
            WHERE t.act = act
            );
--118
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt = (
            SELECT max(dt)
            FROM 
            (
                SELECT t.*, SUM(EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366) OVER(PARTITION BY act ORDER BY dt) sm
                FROM tb t
            ) temp
            WHERE t.act = act
            );
--119
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt = (
            SELECT max(dt)
            FROM 
            (
                SELECT t.*, VAR_POP(EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366) OVER(PARTITION BY act ORDER BY dt DESC) stmp
                FROM tb t
            ) temp
            WHERE t.act = act
            );
--120
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt = (
            SELECT max(dt)
            FROM 
            (
                SELECT t.*, VARIANCE(EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366) OVER(PARTITION BY act ORDER BY dt DESC) stmp
                FROM tb t
            ) temp
            WHERE t.act = act
            );
--121
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt = (
            SELECT max(dt)
            FROM 
            (
                 SELECT t.*, VAR_SAMP(EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366) OVER(PARTITION BY act ORDER BY dt DESC) stmp
                 FROM tb t
            ) temp
            WHERE t.act = act
            );
--122
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt = (
            SELECT max(dt)
            FROM 
            (
                 SELECT t.*, VARIANCE(EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366) OVER(PARTITION BY act ORDER BY dt DESC) stmp
                 FROM tb t
            ) temp
            WHERE t.act = act
            );
--123
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt = (
            SELECT max(dt)
            FROM 
            (
                 SELECT t.*, VAR_SAMP(EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366) OVER(PARTITION BY act ORDER BY dt DESC) stmp
                 FROM tb t
            ) temp
            WHERE t.act = act
            );
--124
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt = (
            SELECT max(dt)
            FROM 
            (
                  SELECT t.*, VARIANCE(EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366) OVER(PARTITION BY act ORDER BY dt DESC) stmp
                  FROM tb t
            ) temp
            WHERE t.act = act
            );
--125
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt = (
            SELECT max(dt)
            FROM 
            (
                  SELECT t.*, VAR_POP(EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366) OVER(PARTITION BY act ORDER BY dt DESC) stmp
                  FROM tb t
            ) temp
            WHERE t.act = act
            );
--126
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt = (
            SELECT max(dt)
            FROM 
            (
                  SELECT t.*, VARIANCE(EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366) OVER(PARTITION BY act ORDER BY dt DESC) stmp
                  FROM tb t
            ) temp
            WHERE t.act = act
            );
--127
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt = (
            SELECT max(dt)
            FROM 
            (
                   SELECT t.*, VAR_SAMP(EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366) OVER(PARTITION BY act ORDER BY dt DESC) stmp
                   FROM tb t
            ) temp
            WHERE t.act = act
            );
--128
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt = (
            SELECT max(dt)
            FROM 
            (
                   SELECT t.*, VARIANCE(EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366) OVER(PARTITION BY act ORDER BY dt DESC) stmp
                   FROM tb t
            ) temp
            WHERE t.act = act
            );
--129
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt = (
            SELECT max(dt)
            FROM 
            (
                   SELECT t.*, VAR_POP(EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366) OVER(PARTITION BY act ORDER BY dt DESC) stmp
                   FROM tb t
            ) temp
            WHERE t.act = act
            );
--130
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt = (
            SELECT max(dt)
            FROM 
            (
                   SELECT t.*, SUM(EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366) OVER(PARTITION BY act ORDER BY dt) sm
                   FROM tb t
            ) temp
            WHERE t.act = act
            );
--131
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt = (
            SELECT max(dt)
            FROM 
            (
                  SELECT t.*, VAR_POP(EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366) OVER(PARTITION BY act ORDER BY dt DESC) stmp
                  FROM tb t
            ) temp
            WHERE t.act = act
            );
--132
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt = (
            SELECT max(dt)
            FROM 
            (
                  SELECT t.*, VARIANCE(EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366) OVER(PARTITION BY act ORDER BY dt DESC) stmp
                  FROM tb t
            ) temp
            WHERE t.act = act
            );
--133
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt = (
            SELECT max(dt)
            FROM 
            (
                  SELECT t.*, VAR_SAMP(EXTRACT(DAY FROM dt) + EXTRACT(MONTH FROM dt)*31 + EXTRACT(YEAR FROM dt)*366) OVER(PARTITION BY act ORDER BY dt DESC) stmp
                  FROM tb t
            ) temp
            WHERE t.act = act
            );
--134
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt = (
            SELECT max(dt)
            FROM 
            (
                  SELECT t.*, ROW_NUMBER() OVER(PARTITION BY act ORDER BY dt DESC) numb
                  FROM tb t
            ) temp
            WHERE t.act = act
            );
--135
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt = (
            SELECT max(dt)
            FROM 
            (
                  SELECT t.*, PERCENT_RANK() OVER(PARTITION BY act ORDER BY dt) pr
                  FROM tb t
            ) temp
            WHERE t.act = act
            );
--136
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt = (
            SELECT max(dt)
            FROM 
            (
                 SELECT t.*, MAX(dt) OVER(PARTITION BY act) max_dt
                 FROM tb t
            ) temp
            WHERE t.act = act
            );
--137
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt = (
            SELECT max(dt)
            FROM 
            (
                 SELECT t.*, LEAD(dt, 1) OVER(PARTITION BY act ORDER BY dt) lead_dt
                 FROM tb t
            ) temp
            WHERE t.act = act
            );
--138
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt = (
            SELECT max(dt)
            FROM 
            (
                 SELECT t.*, LAG(dt, 1) OVER(PARTITION BY act ORDER BY dt DESC) lag_dt
                 FROM tb t
            ) temp
            WHERE t.act = act
            );
--139
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt = (
            SELECT max(dt)
            FROM 
            (
                  SELECT t.*, last_value(dt) OVER(PARTITION BY act) last_val
                  FROM tb t
            ) temp
            WHERE t.act = act
            );
--140
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt = (
            SELECT max(dt)
            FROM 
            (
                  SELECT t.*, first_value(dt) OVER(PARTITION BY act ORDER BY dt DESC) fir_val
                  FROM tb t
            ) temp
            WHERE t.act = act
            );
--141
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt = (
            SELECT max(dt)
            FROM 
            (
                  SELECT t.*, CUME_DIST() OVER(PARTITION BY act ORDER BY dt) cum
                  FROM tb t
            ) temp
            WHERE t.act = act
            );
--142
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt = (
            SELECT max(dt)
            FROM 
            (
                   SELECT t.*, DENSE_RANK() OVER(PARTITION BY act ORDER BY dt DESC) drank
                   FROM tb t
            ) temp
            WHERE t.act = act
            );
--143
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt = (
            SELECT max(dt)
            FROM 
            (
                   SELECT t.*, RANK() OVER(PARTITION BY act ORDER BY dt DESC) drank
                   FROM tb t
            ) temp
            WHERE t.act = act
            );
--144
SELECT act, amt
FROM (
     SELECT t.*, CUME_DIST() OVER(PARTITION BY act ORDER BY dt DESC) cume_d
     FROM tb t
     ) t
WHERE cume_d = (
           SELECT MIN(cume_d)
           FROM(
                  SELECT t.*, CUME_DIST() OVER(PARTITION BY act ORDER BY dt DESC) cume_d
                  FROM tb t
               )tt
           WHERE t.act = tt.act);
--145
SELECT act, amt
FROM (
     SELECT t.*, row_number() OVER(PARTITION BY act ORDER BY dt DESC) d1, DENSE_RANK() OVER(PARTITION BY act ORDER BY dt DESC)  d2
     FROM tb t
     ) t
WHERE d1 = d2 AND d1 = 1;
--146
WITH max_dt AS (
                SELECT DISTINCT MAX(dt) OVER(PARTITION BY act) dt
                FROM tb
               ),
act_list AS (
             SELECT DISTINCT first_value(act) OVER(PARTITION BY act) act
             FROM tb
            )
SELECT t.act, t.amt
FROM tb t, max_dt m, act_list a
WHERE t.act = a.act AND t.dt = m.dt
--147
SELECT act, amt
FROM tb t
WHERE dt = (SELECT DISTINCT MAX(dt) OVER(PARTITION BY act) FROM tb WHERE t.act = act);
--148
WITH temp AS
(
SELECT t.*, row_number() OVER(PARTITION BY act ORDER BY act) r_num
FROM tb t
)

SELECT act, amt
FROM temp t
WHERE r_num = (SELECT MAX(r_num) FROM temp WHERE t.act = act);
--149
SELECT act, amt 
FROM (
      SELECT t.*, REGR_SXY(SYSDATE - dt, amt) OVER(PARTITION BY act ORDER BY dt DESC) stmp
      FROM tb t
     ) temp
WHERE stmp = 0;
--150
SELECT act, amt 
FROM (
      SELECT t.*, REGR_SXX(amt, amt) OVER(PARTITION BY act ORDER BY dt DESC) stmp
      FROM tb t
     ) temp
WHERE stmp = 0;
--151
SELECT act, amt 
FROM (
      SELECT t.*, REGR_SYY(amt, amt) OVER(PARTITION BY act ORDER BY dt DESC) stmp
      FROM tb t
     ) temp
WHERE stmp = 0;
--152
SELECT act, amt 
FROM (
      SELECT t.*, CORR(amt, amt) OVER(PARTITION BY act ORDER BY dt DESC) stmp
      FROM tb t
     ) temp
WHERE stmp IS NULL;
--153
SELECT act, amt 
FROM (
      SELECT t.*, REGR_SXY(amt, amt) OVER(PARTITION BY act  ORDER BY dt DESC ROWS BETWEEN UNBOUNDED PRECEDING AND 0 FOLLOWING) stmp
      FROM tb t
     ) temp
WHERE stmp = 0;
--154
SELECT act, amt 
FROM (
      SELECT t.*, REGR_SXX(amt, amt) OVER(PARTITION BY act  ORDER BY dt DESC ROWS BETWEEN UNBOUNDED PRECEDING AND 0 FOLLOWING) stmp
      FROM tb t
     ) temp
WHERE stmp = 0;
--155
SELECT act, amt 
FROM (
      SELECT t.*, REGR_SYY(amt, amt) OVER(PARTITION BY act  ORDER BY dt DESC ROWS BETWEEN UNBOUNDED PRECEDING AND 0 FOLLOWING) stmp
      FROM tb t
     ) temp
WHERE stmp = 0;
--156
SELECT act, amt 
FROM (
      SELECT t.*, CORR(amt, amt) OVER(PARTITION BY act ORDER BY dt DESC ROWS BETWEEN UNBOUNDED PRECEDING AND 0 FOLLOWING) stmp
      FROM tb t
     ) temp
WHERE stmp IS NULL;
--157
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt IN (
             SELECT dt 
             FROM (
             SELECT t.*, NTILE(5) OVER(PARTITION BY act ORDER BY dt DESC) ntl
             FROM tb t 
             ) temp
             WHERE ntl = 1
             AND t.act = act
            );
--158
SELECT DISTINCT act, amt 
FROM tb t
WHERE dt = (
            SELECT max(dt)
            FROM (
             SELECT t.*, NTILE(2) OVER(PARTITION BY act ORDER BY dt DESC) ntl
             FROM tb t 
             ) temp
             WHERE ntl = 1
            AND t.act = act
            );
--159
SELECT act, amt 
FROM( 
       SELECT DISTINCT act, amt, dt,
                       nth_value(dt, 1) OVER(PARTITION BY act ORDER BY dt DESC 
                       RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS date_in_section 
       FROM tb) a 
WHERE a.dt = date_in_section 
ORDER BY act;















