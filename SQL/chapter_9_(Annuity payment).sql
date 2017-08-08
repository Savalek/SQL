------------------------------------------------------------------------------------------------------------------------------------------
                           -------------------------����� 9. ����������� ������.-----------------------
------------------------------------------------------------------------------------------------------------------------------------------
CREATE TABLE credit_info
(id_client NUMBER(7) PRIMARY KEY,
amount_ NUMBER,
month_ NUMBER(3),
percent_ NUMBER(5,2),
date_ DATE);

TRUNCATE TABLE credit_info;
INSERT INTO credit_info VALUES(1001001, 1000000, 24, 14, to_date('22.03.2017', 'dd.mm.yyyy'));

SELECT * FROM credit_info;
-----function
CREATE OR REPLACE FUNCTION get_annuity_avg(cred_amount IN NUMBER,
                                           year_per    IN NUMBER, 
                                           month_count IN NUMBER) RETURN NUMBER
IS month_per NUMBER := year_per / 100 / 12;
BEGIN RETURN cred_amount * (month_per + (month_per / (POWER( 1 + month_per, month_count) - 1) ) ); END;

CREATE OR REPLACE FUNCTION count_day_in_year(d IN DATE) RETURN NUMBER IS
BEGIN RETURN add_months( TRUNC(d, 'yyyy'), 12 ) - TRUNC(d, 'yyyy'); END;

CREATE OR REPLACE FUNCTION get_percent(d1 IN DATE, d2 IN DATE, year_per IN NUMBER, od IN NUMBER) RETURN NUMBER 
IS percen NUMBER;
BEGIN
  IF TRUNC(d1, 'yyyy') = TRUNC(d2, 'yyyy') THEN
     percen := od * year_per * (d2 - d1) / 100 / count_day_in_year(d1);
  ELSE
     percen := od * year_per * (trunc(d2, 'yyyy') - d1) / 100 / count_day_in_year(d1)
             + od * year_per * (d2 - TRUNC(d2, 'yyyy')) / 100 / count_day_in_year(d2);
  END IF;
  RETURN percen;
END;

SELECT to_date('22/01/2012', 'dd/mm/yyyy') -  
       to_date('22/12/2011', 'dd/mm/yyyy') "1",
       to_date('01/01/2012', 'dd/mm/yyyy') -  
       to_date('22/12/2011', 'dd/mm/yyyy') "2",
       to_date('22/01/2012', 'dd/mm/yyyy') -  
       to_date('01/01/2012', 'dd/mm/yyyy') "3" FROM dual;
-----
SELECT  *
FROM ( SELECT c.*,
              LEVEL - 1 num_pl,
              ADD_MONTHS(c.date_, LEVEL - 1) date_pl, 
              get_annuity_avg(c.amount_, c.percent_, c.month_) amount_all,
              0 amount_percent, 
              0 amount_od,
              CASE LEVEL - 1 WHEN 0 THEN c.amount_ END od_lost,
              c.percent_ y_per
       FROM credit_info c
       CONNECT BY LEVEL - 1 <= c.month_
     )t
MODEL
  DIMENSION BY (num_pl)
  MEASURES (id_client, date_pl, amount_all,  amount_percent, amount_od, od_lost, y_per)
  RULES ( amount_percent[num_pl <> 0] = get_percent(date_pl[CV(num_pl) - 1], date_pl[CV(num_pl)], y_per[CV(num_pl)], od_lost[cv(num_pl) - 1]),
          amount_od[num_pl <> 0]      = amount_all[CV(num_pl)] - amount_percent[CV(num_pl)],   
          od_lost[num_pl <> 0]        = od_lost[CV(num_pl) - 1] - amount_od[CV(num_pl)]
         )
ORDER BY num_pl;
------view
CREATE OR REPLACE VIEW 
SELECT id_client "ID �������",
       0 "� �������",
       0 "���� �������", 
       0 "����� ������� (% + ��)", 
       0 "����� ����������� ���������", 
       0 "����� ��������� ��", 
       0 "������� ��"
FROM credit_info
CONNECT BY LEVEL <= 5;

select add_months(trunc(sysdate,'yyyy'),12)-trunc(sysdate,'yyyy') from dual;

select add_months(trunc(sysdate,'yyyy'),12) "1", trunc(sysdate,'yyyy') "2"  from dual;
---model test
SELECT *
FROM dual
    MODEL DIMENSION BY (5 dimension)
    MEASURES (dummy) 
    RULES (
        dummy[5] = 1,
        dummy[6] = 2,
        dummy[7] = 3
    );
    

SELECT a, b, c, e
FROM( SELECT LEVEL a, LEVEL * 10 b, 0 c, 0 e
      FROM dual
      CONNECT BY LEVEL <= 9)t
MODEL
  DIMENSION BY (a)
  MEASURES (a aa, b, c, e)
  RULES (
         c[ANY] = aa[CV(a)],
         e[ANY] = c[CV(a)]       
         );








