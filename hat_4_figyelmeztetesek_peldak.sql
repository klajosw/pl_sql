-- Munkamenet be�ll�t�sa, figyelmezet�sek tilt�sa
ALTER SESSION SET
  PLSQL_WARNINGS='DISABLE:ALL' 
  PLSQL_CCFLAGS=''
;

-- Cs�nya, de hib�tlan alprogram
CREATE OR REPLACE PROCEDURE proc_warn
IS
  v_Id    VARCHAR2(100);
  v_Name  VARCHAR2(100);
  to_char BOOLEAN;  -- PLW-05004, megengedett, a TO_CHAR nem fenntartott sz�
BEGIN
  $IF $$kojak $THEN $END  -- PLW-06003, kojak nincs a PLSQL_CCFLAGS-ben
  SELECT cim
    INTO v_Name
    FROM konyv
   WHERE id = v_Id  -- PLW-07204, id NUMBER, v_id VARCHAR2
  ;
  IF FALSE THEN
    NULL;  -- PLW-06002, az IF felt�tele mindig hamis
  END IF;
END proc_warn;
/
SHOW ERRORS;
/*
Az elj�r�s l�trej�tt.

Nincsenek hib�k.
*/


-- S�lyos figyelmeztet�sek enged�lyez�se
ALTER PROCEDURE proc_warn COMPILE 
  PLSQL_WARNINGS='DISABLE:ALL', 'ENABLE:SEVERE';
SHOW ERRORS;
/*
SP2-0805: Az elj�r�s ford�t�si figyelmeztet�sekkel lett m�dos�tva.

Hib�k PROCEDURE PROC_WARN:

LINE/COL ERROR
-------- -----------------------------------------------------------------
5/3      PLW-05004: a(z) TO_CHAR azonos�t� a STANDARD csomagban is
         defini�lva van vagy be�p�tett SQL-elem.
*/


-- Teljes�tm�ny figyelmeztet�sek enged�lyez�se
ALTER PROCEDURE proc_warn COMPILE
  PLSQL_WARNINGS='DISABLE:ALL', 'ENABLE:PERFORMANCE';
SHOW ERRORS;
/*
SP2-0805: Az elj�r�s ford�t�si figyelmeztet�sekkel lett m�dos�tva.

Hib�k PROCEDURE PROC_WARN:

LINE/COL ERROR
-------- -----------------------------------------------------------------
11/15    PLW-07204: az oszlop t�pus�t�l elt�r� konverzi� optimum alatti
         lek�rdez�si szerkezetet eredm�nyezhet
*/


-- T�j�koztat� figyelmeztet�sek enged�lyez�se
ALTER PROCEDURE proc_warn COMPILE
  PLSQL_WARNINGS='DISABLE:ALL', 'ENABLE:INFORMATIONAL';
SHOW ERRORS;
/*
SP2-0805: Az elj�r�s ford�t�si figyelmeztet�sekkel lett m�dos�tva.

Hib�k PROCEDURE PROC_WARN:

LINE/COL ERROR
-------- -----------------------------------------------------------------
7/7      PLW-06003: ismeretlen lek�rdez�si direkt�va: '$$KOJAK'
13/6     PLW-06002: Nem el�rhet� k�d
*/


-- Minden figyelmeztet�s legyen ford�t�si hiba
ALTER PROCEDURE proc_warn COMPILE
  PLSQL_WARNINGS='ERROR:ALL';
SHOW ERRORS;
/*
Figyelmeztet�s: Az elj�r�s m�dos�t�sa ford�t�si hib�kkal fejez�d�tt be.

Hib�k PROCEDURE PROC_WARN:

LINE/COL ERROR
-------- -----------------------------------------------------------------
7/7      PLS-06003: ismeretlen lek�rdez�si direkt�va: '$$KOJAK'
*/
