--------СОздание юзера pdp---------
CREATE BIGFILE TABLESPACE pdp_tablespace
  DATAFILE 'pdp_tablespace01.dat'
  SIZE 200M AUTOEXTEND ON;
  
  
ALTER USER pdp_test
IDENTIFIED BY 12345
DEFAULT TABLESPACE pdp_tablespace
QUOTA UNLIMITED ON SYSTEM
ACCOUNT UNLOCK;

GRANT CREATE SESSION TO pdp_test;
GRANT CREATE TABLE TO pdp_test;
GRANT ALTER ANY TABLE TO pdp_test;
GRANT DELETE ANY TABLE TO pdp_test;
GRANT SELECT ANY TABLE TO pdp_test;
GRANT CREATE ANY DIRECTORY TO pdp_test;
GRANT CREATE ANY SEQUENCE TO pdp_test;
GRANT SELECT ANY SEQUENCE TO pdp_test;
GRANT ALTER ANY SEQUENCE TO pdp_test;
GRANT DROP ANY SEQUENCE TO pdp_test;
GRANT CREATE ANY PROCEDURE TO pdp_test;
GRANT ALTER ANY PROCEDURE TO pdp_test;
GRANT DROP ANY PROCEDURE TO pdp_test;
GRANT EXECUTE ANY PROCEDURE TO pdp_test;
GRANT CREATE USER TO pdp_test;
GRANT ALTER USER TO pdp_test;
GRANT DROP USER TO pdp_test;
GRANT CREATE ANY DIRECTORY TO pdp_test;
GRANT DROP ANY DIRECTORY TO pdp_test;
GRANT DROP ANY DIRECTORY TO pdp_test;
GRANT UNLIMITED TABLESPACE TO pdp_test;
GRANT CREATE ANY VIEW TO pdp_test;
GRANT DROP ANY VIEW TO pdp_test;
--------СОздание юзера---------
CREATE USER savalek
IDENTIFIED BY a12345
PROFILE DEFAULT;

--------Пространство----------
CREATE BIGFILE TABLESPACE saval_tablespace
  DATAFILE 'savalek_tablespace01.dat'
  SIZE 20M AUTOEXTEND ON;

--------Изменение юзера-------
ALTER USER savalek
DEFAULT TABLESPACE saval_tablespace
IDENTIFIED BY 12345
QUOTA UNLIMITED ON SYSTEM
ACCOUNT UNLOCK;
--TEMPORARY TABLESPACE saval_temp_table

--------Привилегии--------------
GRANT CREATE SESSION TO savalek;
GRANT CREATE TABLE TO savalek;
GRANT ALTER ANY TABLE TO savalek;
GRANT DELETE ANY TABLE TO savalek;
GRANT SELECT ANY TABLE TO savalek;
GRANT CREATE ANY DIRECTORY TO savalek;
GRANT CREATE ANY SEQUENCE TO savalek;
GRANT SELECT ANY SEQUENCE TO savalek;
GRANT ALTER ANY SEQUENCE TO savalek;
GRANT DROP ANY SEQUENCE TO savalek;
GRANT CREATE ANY PROCEDURE TO savalek;
GRANT ALTER ANY PROCEDURE TO savalek;
GRANT DROP ANY PROCEDURE TO savalek;
GRANT EXECUTE ANY PROCEDURE TO savalek;
GRANT CREATE USER TO savalek;
GRANT ALTER USER TO savalek;
GRANT DROP USER TO savalek;
GRANT CREATE ANY DIRECTORY TO savalek;
GRANT DROP ANY DIRECTORY TO savalek;
GRANT DROP ANY DIRECTORY TO savalek;
GRANT UNLIMITED TABLESPACE TO savalek;
GRANT CREATE ANY VIEW TO savalek;
GRANT DROP ANY VIEW TO savalek;
--dbms_java.revoke_permission ('USER1','java.io.FilePermission','d:\temp\','read,write');
declare
begin
	dbms_java.grant_permission('SAVALEK', 'SYS:java.io.FilePermission', '<<ALL FILES>>', 'read');
  dbms_java.grant_permission('SAVALEK', 'java.net.SocketPermission', '*', 'accept, connect, listen, resolve');
  --dbms_java.revoke_permission('SAVALEK', 'SYS:java.io.FilePermission', 'c:\', 'read, write');
  DBMS_OUTPUT.PUT_LINE('complete');
end;

dbms_java.grant_permission('savalek', 'java.io.FilePermission', 'c:\\', 'read');

-------------Создание тестового юзера------------
DROP USER saval_1;

CREATE USER saval_1
IDENTIFIED BY 12345;

GRANT CREATE SESSION TO saval_1;
GRANT ALTER ANY TABLE TO saval_1;
GRANT SELECT ANY TABLE TO saval_1;
GRANT CREATE TABLE TO saval_1;
GRANT DELETE ANY TABLE TO saval_1;
GRANT EXECUTE ANY PROCEDURE TO saval_1;
GRANT SELECT, INSERT, UPDATE, DELETE ON savalek.people TO saval_1;


















REVOKE CREATE SESSION FROM saval_1;





