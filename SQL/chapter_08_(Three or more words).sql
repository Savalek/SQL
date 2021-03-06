------------------------------------------------------------------------------------------------------------------------------------------
                           -------------------------����� 8. �� ����� ���� ����.-----------------------
                           -------------------------------------------------"�� ���� ��� ���?"---------
------------------------------------------------------------------------------------------------------------------------------------------
CREATE TABLE a_list 
(id_ NUMBER(4) PRIMARY KEY,
author VARCHAR2(50 CHAR),
text VARCHAR2(3000 CHAR));

TRUNCATE TABLE a_list;
INSERT INTO a_list VALUES(1, '��������� ��������� ������',
'�� ����� ������ ���� ��������,
�������� ������ �������,
����� �� � ���� �����������
����� ��������� ����,
��������� ���� ����������,
������ ����������� �����,
������ ����� � �����,
������� ��� � ��������.
�� ��� � ���� � ����� ������������
����� �������� ������� ����,
�����������, �������������,
��������������, ���������,
��������� ���� ���� �����,
���������, ������ �����������,
�������� � ������� ���,
��� �������� ����������
� ������ ��������� �����.');
INSERT INTO a_list VALUES(2, '������� ���������� ���������', '����� �����?������� ����� �����!');
INSERT INTO a_list VALUES(3, '��� ���������� �������',
'���� ����� �� �������!� � ������� ������ �� ���������� ���������� �� ������ � �����, ����� �������� �� ���� � ��������� �� ����.
��� ������ ��� ������������� �� ������ � ���� ��������� � ��������. � ������ ������ �����, �����!� � �� �� ����� ��������, �����?� � ������� ����. � ����� ���� 5 ���� �� ����� ������,
��� ���������, �������� ���������. � ����������� �� ����, ������.
����� ����������, ���� �� ���������. � ������ ��i����� ��� ���� �� �� ����: ����������� ������� ��� �������������� ������� �������, ������� ��� ������� �� ����������� ����, � ������� �� ���� �� �������.
����� ���� ��� �������������. ���� ������, ��� ���� �����, � ����� �������.');
INSERT INTO a_list VALUES(4, 'noname', '������� �����������. ����������� ���� ��-�������. � ����� ������� �����������.');
INSERT INTO a_list VALUES(5, 'TEST1', '����? ��� ���? ��� ��� ���! ��� ���? ����;');
INSERT INTO a_list VALUES(6, 'TEST2', '����? ��� ���? ����� "���" ������� (���) ������:���! ��� ���? ����;');
INSERT INTO a_list VALUES(7, 'TEST3',
'Two roads diverged in a yellow wood,
And sorry I could not travel both
And be one traveler, long I stood
And looked down one as far as  could
To where it bent in the undergrowth.');
INSERT INTO a_list VALUES(8, '������',
'In big city 
Was a bad boy 
And one man fighted with this boy 
And he said to boy 
"You are bad boy"');

-------------------------MAIN SELECT
SELECT * FROM a_list
WHERE regexp_like(lower(text), '(^|[ ":/(/)[:space:]])([[:lower:]]+)([ ":/(/)[:space:]]+[^;!?/.]+)?[ ":/(/)[:space:]]+(\2)([ ":/(/)[:space:]]+[^;!?/.]+)?[ ":/(/)[:space:]]+(\2)([ ":/(/)[:space:]]+[^;!?/.]+)?([;!?/.]|$)');
-----------
SELECT a.*
FROM (SELECT aa.*, 
regexp_instr(lower(text), '(^|[ ":/(/)[:space:]])([[:lower:]]+)([ ":/(/)[:space:]]+[^;!?/.]+)?[ ":/(/)[:space:]]+(\2)([ ":/(/)[:space:]]+[^;!?/.]+)?[ ":/(/)[:space:]]+(\2)([ ":/(/)[:space:]]+[^;!?/.]+)?([;!?/.]|$)') pos_ 
FROM a_list aa) a;

--'(^|[ ":/(/)])([[:lower:]]+)([ ":/(/)]+[^;!?/.]+)?[ ":/(/)]+(\2)([ ":/(/)]+[^;!?/.]+)?[ ":/(/)]+(\2)([ ":/(/)]+[^;!?/.]+)?[;!?/.]'
--1
select str, regexp_replace(t.str, '[[:cntrl:]]') as new_str
from (
      select 'test1'||chr(28) as str from dual
      union all
      select 'test2' from dual
      union all
      select 'test3+_*- =\\\|()^%#3@' from dual
      ) t
where regexp_like(t.str, '[[:cntrl:]]')

--2
--��� ���� ����� ������� ������ �� ���������, ��������� ����������� �;�, ����� ��������������� ��������� ��������.
SELECT regexp_substr(str, '[^;]+', 1, level) str
FROM (SELECT ' 1; 2; test1.; nope' str FROM dual) t
CONNECT BY instr(str, ';', 1, level - 1) > 0;

--3
--���� ����� ������� �� ����� ��������� � ���� ����������� ������, �� ����� ������������ perl ���������
SELECT regexp_substr(str, '\S+', 1, level) str
FROM (SELECT ' 1 alex nope 2 test1.' str FROM dual) t
connect by regexp_substr(str,'\S+',1,level) is not NULL;

--4
--���� ��������� ��������� �� ������ �� ������, �� � �� �������
select
     regexp_substr(str, '[^=]+', 1, 1) as str1,
     regexp_substr(str, '[^=]+', 1, 2) as str2,
     regexp_substr(str, '[^=]+', 1, 3) as str3,
     regexp_substr(str, '[^=]+', 1, 4) as str4
from (
      select regexp_substr(str, '[^@]+', 1, level) str
      from (
            select rtrim('field1=field2=field3=field3_2@field3=field4@field5=field6=field7@','@') str
            from dual)
      CONNECT BY REGEXP_INSTR (str, '@', 1, level - 1) > 0
      );
 
--5
--

with t as
(
select 'a+b-c+d' str from dual
)
select case 
       when level != 1
         then regexp_substr(str, '[*+|-]', 1, level-1)
       end prefix_sign,
       regexp_substr(str, '[^+|-]+', 1, level) str,
       regexp_substr(str, '[*+|-]', 1, level) postfix_sign
from t
CONNECT BY regexp_substr(str, '[^+|-]+', 1, level) is not null;






