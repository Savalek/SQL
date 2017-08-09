CREATE TABLE gas_st
(n NUMBER PRIMARY KEY,
 dl NUMBER 
);

INSERT INTO gas_st VALUES(1, 30);
INSERT INTO gas_st VALUES(2, 15);
INSERT INTO gas_st VALUES(3, 12);
INSERT INTO gas_st VALUES(4, 40);

SELECT * FROM gas_st;

SELECT *
FROM gas_st
MODEL
  DIMENSION BY (n)
  MEASURES (dl, 0 dl_now, 0 gs)
  RULES ITERATE(5) (
                    dl_now[ANY] = dl[CV(n)] / (gs[CV(n)] + 1),
                    gs[ANY] = MAX() 
                   );





