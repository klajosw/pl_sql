CREATE TABLE fa (
  id         NUMBER PRIMARY KEY,
  szulo      NUMBER,
  adat       NUMBER,
  CONSTRAINT fa_fk FOREIGN KEY (szulo) 
    REFERENCES fa(id)
);   
  
INSERT INTO fa VALUES (1, NULL, 10);
INSERT INTO fa VALUES (2, 1, 20);
INSERT INTO fa VALUES (3, 2, 30);
INSERT INTO fa VALUES (4, 2, 40);
INSERT INTO fa VALUES (5, 3, 50);
INSERT INTO fa VALUES (6, 1, 60);
INSERT INTO fa VALUES (7, 1, 70);
INSERT INTO fa VALUES (8, NULL, 80);
INSERT INTO fa VALUES (9, 8, 90);

SELECT LPAD(' ', (LEVEL-1)*3, '|  ') || '+--' 
        || '(' || id || ', ' || adat || ')' AS elem
  FROM fa
  CONNECT BY PRIOR id = szulo
  START WITH szulo IS NULL;
/*
ELEM
---------------------
+--(1, 10)
|  +--(2, 20)
|  |  +--(3, 30)
|  |  |  +--(5, 50)
|  |  +--(4, 40)
|  +--(6, 60)
|  +--(7, 70)
+--(8, 80)
|  +--(9, 90)

9 sor kijelölve.
*/

CREATE OR REPLACE TRIGGER tr_fa
  BEFORE DELETE ON fa
  FOR EACH ROW
BEGIN
  /* Ezt kellene csinálni, ha lehetne: */
  UPDATE fa SET szulo = :OLD.szulo
    WHERE szulo = :OLD.id;
END tr_fa;
/
show errors

DELETE FROM fa WHERE id = 2;
/*
DELETE FROM fa WHERE id = 2;
            *
Hiba a(z) 1. sorban:
ORA-04091: PLSQL.FA tábla változtatás alatt áll, trigger/funkció számára nem látható
ORA-06512: a(z) "PLSQL.TR_FA", helyen a(z) 3. sornál
ORA-04088: hiba a(z) 'PLSQL.TR_FA' trigger futása közben
*/
