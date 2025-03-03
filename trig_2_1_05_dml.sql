/*
  A NEW pszeudov�ltoz� �rt�ke megv�ltoztathat�
  BEFORE triggerben, �s akkor az �j �rt�k ker�l 
  be a t�bl�ba.
*/
CREATE TABLE szam_tabla(a NUMBER);

CREATE OR REPLACE TRIGGER tr_duplaz
  BEFORE INSERT ON szam_tabla
  FOR EACH ROW
BEGIN
  :NEW.a := :NEW.a * 2;
END tr_duplaz;
/

INSERT INTO szam_tabla VALUES(5);

SELECT * FROM szam_tabla;
/*
         A
----------
        10
*/
DROP TRIGGER tr_duplaz;
DROP TABLE szam_tabla;
