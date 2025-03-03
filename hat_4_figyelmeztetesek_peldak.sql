-- Munkamenet beállítása, figyelmezetések tiltása
ALTER SESSION SET
  PLSQL_WARNINGS='DISABLE:ALL' 
  PLSQL_CCFLAGS=''
;

-- Csúnya, de hibátlan alprogram
CREATE OR REPLACE PROCEDURE proc_warn
IS
  v_Id    VARCHAR2(100);
  v_Name  VARCHAR2(100);
  to_char BOOLEAN;  -- PLW-05004, megengedett, a TO_CHAR nem fenntartott szó
BEGIN
  $IF $$kojak $THEN $END  -- PLW-06003, kojak nincs a PLSQL_CCFLAGS-ben
  SELECT cim
    INTO v_Name
    FROM konyv
   WHERE id = v_Id  -- PLW-07204, id NUMBER, v_id VARCHAR2
  ;
  IF FALSE THEN
    NULL;  -- PLW-06002, az IF feltétele mindig hamis
  END IF;
END proc_warn;
/
SHOW ERRORS;
/*
Az eljárás létrejött.

Nincsenek hibák.
*/


-- Súlyos figyelmeztetések engedélyezése
ALTER PROCEDURE proc_warn COMPILE 
  PLSQL_WARNINGS='DISABLE:ALL', 'ENABLE:SEVERE';
SHOW ERRORS;
/*
SP2-0805: Az eljárás fordítási figyelmeztetésekkel lett módosítva.

Hibák PROCEDURE PROC_WARN:

LINE/COL ERROR
-------- -----------------------------------------------------------------
5/3      PLW-05004: a(z) TO_CHAR azonosító a STANDARD csomagban is
         definiálva van vagy beépített SQL-elem.
*/


-- Teljesítmény figyelmeztetések engedélyezése
ALTER PROCEDURE proc_warn COMPILE
  PLSQL_WARNINGS='DISABLE:ALL', 'ENABLE:PERFORMANCE';
SHOW ERRORS;
/*
SP2-0805: Az eljárás fordítási figyelmeztetésekkel lett módosítva.

Hibák PROCEDURE PROC_WARN:

LINE/COL ERROR
-------- -----------------------------------------------------------------
11/15    PLW-07204: az oszlop típusától eltérõ konverzió optimum alatti
         lekérdezési szerkezetet eredményezhet
*/


-- Tájékoztató figyelmeztetések engedélyezése
ALTER PROCEDURE proc_warn COMPILE
  PLSQL_WARNINGS='DISABLE:ALL', 'ENABLE:INFORMATIONAL';
SHOW ERRORS;
/*
SP2-0805: Az eljárás fordítási figyelmeztetésekkel lett módosítva.

Hibák PROCEDURE PROC_WARN:

LINE/COL ERROR
-------- -----------------------------------------------------------------
7/7      PLW-06003: ismeretlen lekérdezési direktíva: '$$KOJAK'
13/6     PLW-06002: Nem elérhetõ kód
*/


-- Minden figyelmeztetés legyen fordítási hiba
ALTER PROCEDURE proc_warn COMPILE
  PLSQL_WARNINGS='ERROR:ALL';
SHOW ERRORS;
/*
Figyelmeztetés: Az eljárás módosítása fordítási hibákkal fejezõdött be.

Hibák PROCEDURE PROC_WARN:

LINE/COL ERROR
-------- -----------------------------------------------------------------
7/7      PLS-06003: ismeretlen lekérdezési direktíva: '$$KOJAK'
*/
