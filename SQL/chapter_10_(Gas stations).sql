CREATE TABLE gas_st
(n NUMBER PRIMARY KEY,
 dl NUMBER 
);

TRUNCATE TABLE gas_st;
INSERT INTO gas_st VALUES(1, 30);
INSERT INTO gas_st VALUES(2, 15);
INSERT INTO gas_st VALUES(3, 12);
INSERT INTO gas_st VALUES(4, 40);

DROP TABLE gas_add_count;
CREATE TABLE gas_add_count
(gs_cnt NUMBER
);

TRUNCATE TABLE gas_add_count;
INSERT INTO gas_add_count VALUES(5);

SELECT * FROM gas_st;

CREATE OR REPLACE VIEW gas_add_view AS
SELECT *
FROM gas_st, gas_add_count
MODEL
  DIMENSION BY (n)
  MEASURES (dl, 0 dl_now, 0 gs, 0 gs_add, gs_cnt)
  RULES ITERATE(100500) UNTIL (iteration_number = gs_cnt[1] - 1)(
                    dl_now[ANY] = dl[CV(n)] / (gs[CV(n)] + 1),
                    gs_add[ANY] = CASE MAX(dl_now)[ANY] WHEN dl_now[CV(n)] THEN 1 ELSE 0 END,
                    gs_add[ANY] = CASE SUM(gs_add)[ANY] WHEN 1 THEN gs_add[CV(n)] ELSE 0 END,
                    gs[ANY] = gs[CV(n)] + gs_add[CV(n)]
                    --gs[ANY] = gs[CV(n)] + CASE MAX(dl_now)[ANY] WHEN dl_now[CV(n)] THEN 1 ELSE 0 END
                   );


SELECT nm "№ Промежутка", dl "Расстояние"
FROM  (SELECT temp.*, coalesce(LAG(max_, 1) OVER(ORDER BY n) + 1, 1) min_
      FROM (SELECT n, dl/(gs+1) dl, SUM(gs+1) OVER(ORDER BY n) max_
            FROM gas_add_view) temp) vt,
      (SELECT LEVEL nm
      FROM dual
      CONNECT BY LEVEL <=   (SELECT MAX(n) FROM gas_st) 
                          + (SELECT gs_cnt FROM gas_add_count)) t
WHERE nm BETWEEN min_ AND max_;
 





