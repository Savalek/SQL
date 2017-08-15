-------myJavaLibraryTest /begin------
--init
CREATE OR REPLACE FUNCTION factorial(n IN NUMBER) RETURN NUMBER
AS LANGUAGE JAVA NAME 'SavalClass.fact(long) return long';

--test
SELECT factorial(LEVEL)
FROM dual
CONNECT BY LEVEL <= 30;

-------myJavaLibraryTest /start------
--JAVA----------------------------------------------
----------------------------------------------------------------------
DROP FUNCTION get_ten;

CREATE OR REPLACE FUNCTION add_one(n IN NUMBER) RETURN NUMBER
AS LANGUAGE JAVA NAME 'Adder.addOne (int) return int';

CREATE OR REPLACE FUNCTION mult_ten(n IN NUMBER) RETURN NUMBER
AS LANGUAGE JAVA NAME 'Adder.multTen (int) return int';

--JAVA TEST
SELECT add_one(10) AS a, mult_ten(5) AS b
FROM dual;
-
---------------------JAVA_SAVAL_MATH


--summ BigInteger
CREATE OR REPLACE FUNCTION sm_sum(a IN VARCHAR2, b IN VARCHAR2) RETURN VARCHAR2
AS LANGUAGE JAVA NAME 'SavMath.sum (java.lang.String, java.lang.String) return String';

SELECT sm_sum('3333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333',
              '4444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444') "Сумма" FROM dual;
--minus BigInteger
CREATE OR REPLACE FUNCTION sm_minus(a IN VARCHAR2, b IN VARCHAR2) RETURN VARCHAR2
AS LANGUAGE JAVA NAME 'SavMath.minus(java.lang.String, java.lang.String) return String';

SELECT sm_minus('9999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999',
                '8888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888') "Разность"
FROM dual;
--mult BigInteger
CREATE OR REPLACE FUNCTION sm_mult(a IN VARCHAR2, b IN VARCHAR2) RETURN VARCHAR2
AS LANGUAGE JAVA NAME 'SavMath.mult (java.lang.String, java.lang.String) return String';

SELECT sm_mult('874569238723434563456345634563456345634634564356345645643567356776846598372873457624057028974502874508726048560282736450728346508578',
               '1098450897345806203847560287425465675678657896890678946736734562456456508273465807260348756028475028734650827460582640587208727') "Умножение"
FROM dual;
--div BigInteger
CREATE OR REPLACE FUNCTION sm_div(a IN VARCHAR2, b IN VARCHAR2) RETURN VARCHAR2
AS LANGUAGE JAVA NAME 'SavMath.div(java.lang.String, java.lang.String) return String';

SELECT sm_div('987345846892753465897234687956298374652387465982734659873246872687523485702389475027889750293268745628736582736582736458923745982734529873423452345',
              '24987503456345737634562345634563456345634563456345722893479753249') "Целочисленное Деление"
FROM dual;
--mod BigInteger
CREATE OR REPLACE FUNCTION sm_mod(a IN VARCHAR2, b IN VARCHAR2) RETURN VARCHAR2
AS LANGUAGE JAVA NAME 'SavMath.mod(java.lang.String, java.lang.String) return String';

SELECT sm_mod('98734584689275334658972346879562983746523874659827346598732468726875234857027889750293268745628736582736582736458923745982734529873423452345',
              '23') "Остаток от деления"
FROM dual;
--power BigInteger
CREATE OR REPLACE FUNCTION sm_power(a IN VARCHAR2, b IN VARCHAR2) RETURN VARCHAR2
AS LANGUAGE JAVA NAME 'SavMath.power(java.lang.String, java.lang.String) return String';

SELECT sm_power('1234', '12') "Степень"
FROM dual;

SELECT LEVEL "Степень", sm_power('2', LEVEL) "Значение"
FROM dual
CONNECT BY LEVEL <= 1000;
-------------------JAVA_SAVAL_MATH_END
--list files
CREATE OR REPLACE FUNCTION get_files_list(path_ IN VARCHAR2, max_deep IN NUMBER) RETURN VARCHAR2
AS LANGUAGE JAVA NAME 'SavMath.getFiles (java.lang.String, int) return String';

SELECT get_files_list FROM dual;

DECLARE
BEGIN
  dbms_output.put_line(get_files_list('c:\', 1));
END;

--ARRAY test
CREATE OR REPLACE TYPE fname_array IS VARRAY(3000) OF VARCHAR2(2000);
CREATE OR REPLACE FUNCTION get_array_files(arr IN fname_array) RETURN fname_array
AS LANGUAGE JAVA NAME '';

--httpsGet
CREATE OR REPLACE FUNCTION get_html(url_ IN VARCHAR2) RETURN VARCHAR2
AS LANGUAGE JAVA NAME 'HTTPGet.getHTML (java.lang.String) return String';

BEGIN
  DBMS_OUTPUT.ENABLE(10000000);
  dbms_output.put_line(get_html('http://www.google.ru/'));
END;
--httpGet CLOB
CREATE OR REPLACE FUNCTION get_html_clob (url_ IN VARCHAR2) RETURN CLOB
AS LANGUAGE JAVA NAME 'HTTPGet.getHTML_clob (java.lang.String) return CLOB';

BEGIN
  dbms_output.ENABLE(1000000);
  dbms_output.put_line(get_html_clob('http://www.google.ru/'));
END;


DECLARE
clob_ CLOB;
vchar VARCHAR2(2000 CHAR);
i NUMBER(9);
BEGIN
  dbms_output.ENABLE(100000);
  clob_ := get_html_clob('http://www.google.ru/');
  i := 1;
  --FOR i IN 1..500
    LOOP
      vchar := SUBSTR(clob_, 1 + (i - 1)*1000, 1000);
      --dbms_output.put_line(i||'<>'||(i - 1)*100||'<>'||i*100||'|'||vchar||'|');
      dbms_output.put_line(vchar);
      i := i + 1;
      EXIT wHEN i > 200 OR vchar IS NULL;
    END LOOP;
END;


SELECT get_html_clob('http://www.google.ru/') FROM DUAL;
