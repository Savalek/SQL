--type
CREATE TYPE book_type AS OBJECT
(bname VARCHAR2(30),
 color VARCHAR2(10));

DROP TABLE libr;
CREATE TABLE libr 
(pname VARCHAR2(20),
 book book_type);
 
INSERT INTO libr VALUES('Олег', NEW book_type('Игра престолов', 'red'));
INSERT INTO libr VALUES('Настя', NEW book_type('Библия', 'black'));

SELECT * FROM libr;

CREATE TABLE books_list OF book_type;

TRUNCATE TABLE books_list;
INSERT INTO books_list VALUES('Том 1', 'red');
INSERT INTO books_list VALUES('Том 2', 'green');
INSERT INTO books_list VALUES('Том 3', 'blue');
INSERT INTO books_list VALUES('Игра престолов', 'red');
INSERT INTO books_list VALUES('Библия', 'black');

UPDATE TABLE books_list SET bname = 'ТОМ 1' WHERE bname = 'Том 1';

SELECT * FROM books_list;

SELECT VALUE(b) FROM books_list b;

SELECT REF(b) "ref", VALUE(b) FROM books_list b;

CREATE TABLE libr_list
(pname VARCHAR2(30),
book REF book_type SCOPE IS books_list);

INSERT INTO libr_list 
VALUES('Кирилл', (SELECT REF(b) FROM books_list b 
                  WHERE bname = 'Игра престолов'));

SELECT pname "Имя", t.dr.bname "Название книги", t.dr.color "Цвет книги"
FROM (SELECT ll.pname, DEREF(book) dr --важно!!!!!!!!!!!!!
      FROM libr_list ll) t

SELECT ll.pname "Имя", bl.bname "Название книги", bl.color "Цвет книги"
FROM libr_list ll
LEFT JOIN books_list bl ON ll.book = REF(bl);

-----------------------------------------------------------nested tables
CREATE TYPE xx_type_pda IS TABLE OF VARCHAR2(100);

CREATE TABLE gadj(id_ NUMBER, jd_list xx_type_pda)
  NESTED TABLE jd_list STORE AS nested_jd_list;

INSERT INTO gadj VALUES(1, NEW xx_type_pda('Galaxy S6', 'LG G2', 'Nokia 3210'));
INSERT INTO gadj VALUES(2, NEW xx_type_pda('ZTE X3', 'LG et75'));

SELECT * FROM gadj;
SELECT g.id_, gl.* FROM gadj g, TABLE(g.jd_list) gl;
SELECT VALUE(t) FROM THE (SELECT jd_list FROM gadj g WHERE id_ = 1) t;













         
