/*
  A NEW pszeudováltozó értéke megváltoztatható
  BEFORE triggerben, és akkor az új érték kerül 
  be a táblába.
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
