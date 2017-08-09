------------------------------------------------------------------------------------------------------------------------------------------
                           -------------------------Глава 9. Аннуитетный платеж.-----------------------
------------------------------------------------------------------------------------------------------------------------------------------
CREATE TABLE credit_info
(id_client NUMBER(7) PRIMARY KEY,
amount_ NUMBER,
month_ NUMBER(3),
percent_ NUMBER(5,2),
date_ DATE);

TRUNCATE TABLE credit_info;
INSERT INTO credit_info VALUES(1001001, 1000000, 24, 14, to_date('22.03.2017', 'dd.mm.yyyy'));--my
INSERT INTO credit_info VALUES(1231239, 100000,  240, 10, to_date('01.01.2010', 'dd.mm.yyyy'));--viki
INSERT INTO credit_info VALUES(4564560, 100000,  12, 12, to_date('01.01.2010', 'dd.mm.yyyy'));--viki_bank
SELECT * FROM credit_info;
-----function
CREATE OR REPLACE FUNCTION get_annuity_avg(cred_amount IN NUMBER,
                                           year_per    IN NUMBER, 
                                           month_count IN NUMBER) RETURN NUMBER
IS month_per NUMBER := year_per / 10 / 12;
BEGIN RETURN cred_amount * (month_per + (month_per / (POWER( 1 + month_per, month_count) - 1) ) ); END; --My

CREATE OR REPLACE FUNCTION get_annuity_avg(cred_amount IN NUMBER,
                                           year_per    IN NUMBER, 
                                           month_count IN NUMBER) RETURN NUMBER
IS month_per NUMBER := year_per / 100 / 12;
BEGIN  RETURN cred_amount * month_per / (1 - POWER((1 + month_per), - month_count) ); END; --VikiBank

SELECT get_annuity_avg(100000, 12, 12) "PL" FROM dual;
SELECT get_annuity_avg(1000000, 14, 24) "PL" FROM dual;

CREATE OR REPLACE FUNCTION count_day_in_year(d IN DATE) RETURN NUMBER IS
BEGIN RETURN add_months( TRUNC(d, 'yyyy'), 12 ) - TRUNC(d, 'yyyy'); END;

CREATE OR REPLACE FUNCTION get_percent(d1 IN DATE, d2 IN DATE, year_per IN NUMBER, od IN NUMBER) RETURN NUMBER -- my
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

SELECT get_percent(to_date('22/03/2017', 'dd/mm/yyyy'),
                   to_date('22/04/2017', 'dd/mm/yyyy'), 14, 1000000) "PRECENT" FROM dual;
--11190,5790530357 X
--11 666.67        Y

CREATE OR REPLACE FUNCTION get_percent(d1 IN DATE, d2 IN DATE, year_per IN NUMBER, od IN NUMBER) RETURN NUMBER -- VikiPercent
IS percen NUMBER;
BEGIN
  IF TRUNC(d1, 'yyyy') = TRUNC(d2, 'yyyy') THEN
     percen := od * ( POWER(1 + year_per/100, (d2 - d1)/count_day_in_year(d1)) - 1 );
  ELSE
     percen := od * ( POWER(1 + year_per/100, (d2 - TRUNC(d2, 'yyyy'))/count_day_in_year(d1)) - 1 )
             + od * ( POWER(1 + year_per/100, (d2 - TRUNC(d2, 'yyyy'))/count_day_in_year(d2)) - 1 );
  END IF;
  RETURN percen;
END;

SELECT get_percent(to_date('01/01/2010', 'dd/mm/yyyy'),
                   to_date('01/02/2010', 'dd/mm/yyyy'), 10, 100000) "PRECENT" FROM dual;

SELECT to_date('22/01/2012', 'dd/mm/yyyy') -  
       to_date('22/12/2011', 'dd/mm/yyyy') "1",
       to_date('01/01/2012', 'dd/mm/yyyy') -  
       to_date('22/12/2011', 'dd/mm/yyyy') "2",
       to_date('22/01/2012', 'dd/mm/yyyy') -  
       to_date('01/01/2012', 'dd/mm/yyyy') "3" FROM dual;
-----
CREATE OR REPLACE VIEW cred_detail AS
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
MODEL RETURN UPDATED ROWS
  PARTITION BY (id_client)
  DIMENSION BY (num_pl)
  MEASURES (date_pl, amount_all,  amount_percent, amount_od, od_lost, y_per)
  RULES 
 (  
    od_lost[num_pl <> 0] = --CASE WHEN CV(num_pl) = 24 THEN 0 ELSE
    od_lost[CV(num_pl) - 1] - (amount_all[CV(num_pl)] - get_percent(date_pl[CV(num_pl) - 1], date_pl[CV(num_pl)], y_per[CV(num_pl)], od_lost[cv(num_pl) - 1])), --END,
    amount_od[num_pl <> 0]      = od_lost[CV(num_pl) - 1] - od_lost[CV(num_pl)],
    amount_percent[num_pl <> 0] = get_percent(date_pl[CV(num_pl) - 1], date_pl[CV(num_pl)], y_per[CV(num_pl)], od_lost[cv(num_pl) - 1])--amount_all[CV(num_pl)] - amount_od[CV(num_pl)]
 )
ORDER BY num_pl;

SELECT * FROM beatif_cred_detail;
------view
CREATE OR REPLACE VIEW beatif_cred_detail AS
SELECT id_client   "ID Клиента",
       num_pl      "№ платежа",
       date_pl     "Дата платежа", 
       round(amount_all, 2)     "all",--"Сумма платежа (% + ОД)", 
       round(amount_percent, 2) "percent",--"Сумма начисленных процентов", 
       round(amount_od, 2)      "od_min",--"Сумма погашения ОД", 
       round(od_lost, 2)        "od_lost"--"Остаток ОД"
FROM cred_detail;

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
--------------------------
amount_percent[num_pl <> 0] = get_percent(date_pl[CV(num_pl) - 1], date_pl[CV(num_pl)], y_per[CV(num_pl)], od_lost[cv(num_pl) - 1]),
amount_od[num_pl <> 0]      = amount_all[CV(num_pl)] - amount_percent[CV(num_pl)],   
od_lost[num_pl <> 0]        = od_lost[CV(num_pl) - 1] - amount_od[CV(num_pl)]
--------------------------







