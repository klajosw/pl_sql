/*
  Rekurziv triggerek.
*/
CREATE TABLE tab_1 (a NUMBER);
INSERT INTO tab_1 VALUES(1);
CREATE TABLE tab_2 (a NUMBER);
INSERT INTO tab_2 VALUES(1);

CREATE OR REPLACE TRIGGER tr_tab1
  BEFORE DELETE ON tab_1
BEGIN
  DELETE FROM tab_2;
END tr_tab1;
/

CREATE OR REPLACE TRIGGER tr_tab2
  BEFORE DELETE ON tab_2
BEGIN
  DELETE FROM tab_1;
END tr_tab2;
/

DELETE FROM tab_1;
/*
Hiba a(z) 1. sorban:
ORA-00036: a rekurz�v SQL szintek maxim�lis sz�m�nak (50) t�ll�p�se
...
*/

/*
  Mi lesz az eredm�ny sorszint� triggerek eset�n?
*/
