/*
  Deadlock az AUTONOMOUS_TRANSACTION miatt rekurz�v triggerekben.
*/
CREATE TABLE tab_1 (a NUMBER);
INSERT INTO tab_1 VALUES(1);
CREATE TABLE tab_2 (a NUMBER);
INSERT INTO tab_2 VALUES(1);

CREATE OR REPLACE TRIGGER tr_tab1
  AFTER DELETE ON tab_1
  FOR EACH ROW
DECLARE
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
  DELETE FROM tab_2;
END tr_tab1;
/

CREATE OR REPLACE TRIGGER tr_tab2
  AFTER DELETE ON tab_2
  FOR EACH ROW
DECLARE
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
  DELETE FROM tab_1;
END tr_tab2;
/

DELETE FROM tab_1;
/*
Eredm�ny:

DELETE FROM tab_1
            *
Hiba a(z) 1. sorban:
ORA-00060: er�forr�sra v�rakoz�s k�zben holtpont j�tt l�tre
ORA-06512: a(z) "PLSQL.TR_TAB2", helyen a(z) 4. sorn�l
ORA-04088: hiba a(z) 'PLSQL.TR_TAB2' trigger fut�sa k�zben
ORA-06512: a(z) "PLSQL.TR_TAB1", helyen a(z) 4. sorn�l
ORA-04088: hiba a(z) 'PLSQL.TR_TAB1' trigger fut�sa k�zben
*/

