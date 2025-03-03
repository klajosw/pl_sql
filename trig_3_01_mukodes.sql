/*
  A következõ példa demonstrálja
  a triggerek végrehajtási sorrendjét.
*/
CREATE TABLE tabla (a NUMBER);
DELETE FROM tabla; 

INSERT INTO tabla VALUES(1);
INSERT INTO tabla VALUES(2);
INSERT INTO tabla VALUES(3);

CREATE TABLE tabla_log(s VARCHAR2(30));
DELETE FROM tabla_log;

CREATE OR REPLACE PROCEDURE tabla_insert(
  p         tabla_log.s%TYPE
) IS
BEGIN
  INSERT INTO tabla_log VALUES(p);
END tabla_insert;
/

CREATE OR REPLACE TRIGGER tr_utasitas_before
  BEFORE INSERT OR UPDATE OR DELETE ON tabla
CALL tabla_insert('UTASITAS BEFORE')
/

CREATE OR REPLACE TRIGGER tr_utasitas_after
  AFTER INSERT OR UPDATE OR DELETE ON tabla
CALL tabla_insert('UTASITAS AFTER')
/

CREATE OR REPLACE TRIGGER tr_sor_before
  BEFORE INSERT OR UPDATE OR DELETE ON tabla
  FOR EACH ROW
CALL tabla_insert('sor before ' || :OLD.a || ', ' || :NEW.a)
/

CREATE OR REPLACE TRIGGER tr_sor_after
  AFTER INSERT OR UPDATE OR DELETE ON tabla
  FOR EACH ROW
CALL tabla_insert('sor after ' || :OLD.a || ', ' || :NEW.a)
/

UPDATE tabla SET a = a+10;

SELECT * FROM tabla_log;
/*

S
------------------------------
UTASITAS BEFORE
sor before 1, 11
sor after 1, 11
sor before 2, 12
sor after 2, 12
sor before 3, 13
sor after 3, 13
UTASITAS AFTER

*/

