CREATE TABLE gas_st
(n NUMBER PRIMARY KEY,
 dl NUMBER 
);

TRUNCATE TABLE gas_st;
INSERT INTO gas_st VALUES(1, 30);
INSERT INTO gas_st VALUES(2, 15);
INSERT INTO gas_st VALUES(3, 12);
INSERT INTO gas_st VALUES(4, 40);
INSERT INTO gas_st VALUES(5, 40);

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


SELECT nm "� ����������", dl "����������"
FROM  (SELECT temp.*, coalesce(LAG(max_, 1) OVER(ORDER BY n) + 1, 1) min_
      FROM (SELECT n, dl/(gs+1) dl, SUM(gs+1) OVER(ORDER BY n) max_
            FROM gas_add_view) temp) vt,
      (SELECT LEVEL nm
      FROM dual
      CONNECT BY LEVEL <=   (SELECT MAX(n) FROM gas_st) 
                          + (SELECT gs_cnt FROM gas_add_count)) t
WHERE nm BETWEEN min_ AND max_;
 
-----------------------------------------------��������� �� �� ���� ���...
CREATE OR REPLACE TYPE num_arr IS TABLE OF NUMBER;

CREATE TABLE my_map(n NUMBER(20) PRIMARY KEY, nums num_arr)
  NESTED TABLE nums STORE AS nested_nums;
  
TRUNCATE TABLE my_map;
INSERT INTO my_map VALUES(1, NEW num_arr(11, 22, 33));
INSERT INTO my_map VALUES(2, NEW num_arr(44, 55, 66));

INSERT INTO my_map

CREATE OR REPLACE VIEW comb_arr as
WITH arr_list AS ( SELECT MOD(LEVEL - 1, (SELECT gs_cnt+1 FROM gas_add_count)) n
                   FROM dual
                   CONNECT BY LEVEL <= (SELECT gs_cnt+1 FROM gas_add_count)*(SELECT COUNT(*) FROM gas_st) ),
comb_list AS                               
(SELECT ROWNUM r_num, col
FROM (
      SELECT COLUMN_VALUE col
      FROM TABLE(POWERMULTISET_BY_CARDINALITY( 
                                               (SELECT CAST(COLLECT(ar.n) AS num_arr) AS my_collect FROM arr_list ar),
                                               (SELECT COUNT(*) FROM gas_st)) ) tt
     ) t
)
SELECT r_num, col
FROM(
SELECT r_num, col, COLUMN_VALUE,SUM(COLUMN_VALUE)OVER(PARTITION BY r_num) sm, row_number() OVER(PARTITION BY r_num ORDER BY r_num) r_num2
FROM comb_list cb, TABLE(cb.col) cb_col) t
WHERE sm = 5 AND r_num2 = 1;


SELECT r_num, new_gs, dl, dl/(new_gs + 1) dl_new, MAX(dl_new) OVER(partiton)
FROM (SELECT cb.*, COLUMN_VALUE new_gs, row_number() OVER(PARTITION BY r_num ORDER BY r_num) gs_num
      FROM comb_arr cb, TABLE(cb.col) cnt) t
      LEFT JOIN gas_st gs ON gs.n = t.gs_num




SELECT * FROM my_map m, TABLE(m.nums) n;
--gas_st(n, dl)
--gas_add_count(gs_cnt)

SELECT CAST(COLLECT(g.n) AS num_arr) AS my_collect FROM gas_st g;

CREATE TABLE ttt
(n NUMBER(10),
c VARCHAR(10 CHAR));

TRUNCATE TABLE ttt;
INSERT INTO ttt VALUES(1,'a');
INSERT INTO ttt VALUES(2,'b');
INSERT INTO ttt VALUES(3,'c');
INSERT INTO ttt VALUES(4,'a');
INSERT INTO ttt VALUES(1,'b');
INSERT INTO ttt VALUES(2,'c');

SELECT ttt.*, COUNT(c) OVER(ORDER BY n) cnt, SUM(n) OVER() sm FROM ttt;

















