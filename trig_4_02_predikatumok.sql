/*
  A példa a függvények használatát demonstrálja DML-utasításokban.

  A szükséges táblák és az eljárás az elõzõ példában voltak definiálva.
*/
CREATE OR REPLACE TRIGGER tr_utasitas_before
  BEFORE INSERT OR UPDATE OR DELETE ON tabla
BEGIN
  tabla_insert('UTASITAS BEFORE '
     || CASE
          WHEN INSERTING THEN 'INSERT'
          WHEN UPDATING  THEN 'UPDATE'
          WHEN DELETING  THEN 'DELETE'
        END);
END tr_utasitas_before;
/

CREATE OR REPLACE TRIGGER tr_utasitas_after
  AFTER INSERT OR UPDATE OR DELETE ON tabla
BEGIN
  tabla_insert('UTASITAS AFTER '
     || CASE
          WHEN INSERTING THEN 'INSERT'
          WHEN UPDATING  THEN 'UPDATE'
          WHEN DELETING  THEN 'DELETE'
        END);
END tr_utasitas_after;
/
show errors;

CREATE OR REPLACE TRIGGER tr_sor_before
  BEFORE INSERT OR UPDATE OR DELETE ON tabla
  FOR EACH ROW
BEGIN
  tabla_insert('sor before ' || :OLD.a || ', ' || :NEW.a 
     || ' ' || CASE
          WHEN INSERTING THEN 'insert'
          WHEN UPDATING  THEN 'update'
          WHEN DELETING  THEN 'delete'
        END);
END tr_sor_before;
/
show errors;

CREATE OR REPLACE TRIGGER tr_sor_after
  AFTER INSERT OR UPDATE OR DELETE ON tabla
  FOR EACH ROW
BEGIN
  tabla_insert('sor after ' || :OLD.a || ', ' || :NEW.a
     || ' ' || CASE
          WHEN INSERTING THEN 'insert'
          WHEN UPDATING  THEN 'update'
          WHEN DELETING  THEN 'delete'
        END);
END tr_sor_after;
/

DELETE FROM tabla; 
DELETE FROM tabla_log;

-- Biztosan létezik 2 tábla a sémában. */
INSERT INTO tabla
  (SELECT ROWNUM FROM tab WHERE ROWNUM <= 2);

UPDATE tabla SET a = a+10;

DELETE FROM tabla;

SELECT * FROM tabla_log;
/*
S
------------------------------
UTASITAS BEFORE INSERT
sor before , 1 insert
sor after , 1 insert
sor before , 2 insert
sor after , 2 insert
UTASITAS AFTER INSERT
UTASITAS BEFORE UPDATE
sor before 1, 11 update
sor after 1, 11 update
sor before 2, 12 update
sor after 2, 12 update
UTASITAS AFTER UPDATE
UTASITAS BEFORE DELETE
sor before 11,  delete
sor after 11,  delete
sor before 12,  delete
sor after 12,  delete
UTASITAS AFTER DELETE
*/

