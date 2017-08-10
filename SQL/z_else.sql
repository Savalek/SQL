------------------------------------------------------------------------------------------------------------------------------------------
                          -------------------------����� @?"X_0. RECYCLE BIN.-----------------------
------------------------------------------------------------------------------------------------------------------------------------------
--ROWID
SELECT staff.*, ROWID FROM staff;
--������ �������
  SELECT COALESCE(CAST(ID_WORKER AS VARCHAR2(20)), '����� ����:') AS ID_WORKER,
         SUM(VSIZE(ID_WORKER)) BT1,
         COALESCE(CAST(ID_SHOP AS VARCHAR2(20)), '����� ����:') AS ID_SHOP,
         SUM(VSIZE(ID_SHOP)) BT2,
         COALESCE(CAST(SALARY AS VARCHAR2(20)), '����� ����:') AS SALARY,
         SUM(VSIZE(SALARY)) BT3,
         COALESCE(CAST(WNAME AS VARCHAR2(20)), '����� ����:') AS WNAME,
         SUM(VSIZE(WNAME)) BT4,
         COALESCE(CAST(AGE AS VARCHAR2(20)), '����� ����:') AS AGE,
         SUM(VSIZE(AGE)) BT5,
         COALESCE(CAST(ROWID AS VARCHAR2(20)), '����� ����:') AS ROWID_,
         SUM(VSIZE(ROWID)) BT6
    FROM STAFF
   GROUP BY GROUPING SETS((ID_WORKER, ID_SHOP, SALARY, WNAME, AGE, ROWID),());
--dump
SELECT id_worker, id_shop, salary, wname, age
FROM staff;

SELECT dump(id_worker), dump(id_shop), dump(salary), dump(wname), dump(age)
FROM staff;
