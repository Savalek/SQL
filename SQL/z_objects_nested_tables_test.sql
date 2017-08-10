--type
CREATE TYPE book_type AS OBJECT
(bname VARCHAR2(30),
 color VARCHAR2(10));

DROP TABLE libr;
CREATE TABLE libr 
(pname VARCHAR2(20),
 book book_type);
 
INSERT INTO libr VALUES('����', NEW book_type('���� ���������', 'red'));
INSERT INTO libr VALUES('�����', NEW book_type('������', 'black'));

SELECT * FROM libr;

CREATE TABLE books_list OF book_type;

TRUNCATE TABLE books_list;
INSERT INTO books_list VALUES('��� 1', 'red');
INSERT INTO books_list VALUES('��� 2', 'green');
INSERT INTO books_list VALUES('��� 3', 'blue');
INSERT INTO books_list VALUES('���� ���������', 'red');
INSERT INTO books_list VALUES('������', 'black');

UPDATE TABLE books_list SET bname = '��� 1' WHERE bname = '��� 1';

SELECT * FROM books_list;

SELECT VALUE(b) FROM books_list b;

SELECT REF(b) "ref", VALUE(b) FROM books_list b;

CREATE TABLE libr_list
(pname VARCHAR2(30),
book REF book_type SCOPE IS books_list);

INSERT INTO libr_list 
VALUES('������', (SELECT REF(b) FROM books_list b 
                  WHERE bname = '���� ���������'));

SELECT pname "���", t.dr.bname "�������� �����", t.dr.color "���� �����"
FROM (SELECT ll.pname, DEREF(book) dr --�����!!!!!!!!!!!!!
      FROM libr_list ll) t

SELECT ll.pname "���", bl.bname "�������� �����", bl.color "���� �����"
FROM libr_list ll
LEFT JOIN books_list bl ON ll.book = REF(bl);
--nested tables























         
