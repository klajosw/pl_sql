-- Csomag inicializálással és az inicializálástól nem függõ tagokkal

CREATE OR REPLACE PACKAGE csomag_inittel
IS
  -- Néhány csomagolt elem
  c_Konstans CONSTANT  NUMBER := 10;
  v_Valtozo            NUMBER := 10;
  TYPE t_rec IS RECORD (id NUMBER, nev VARCHAR2(10000));

END csomag_inittel;
/

CREATE OR REPLACE PACKAGE BODY csomag_inittel
IS
-- Csomaginicializáló blokk
BEGIN
  DBMS_OUTPUT.PUT_LINE('Csomaginicializáló blokk.');
  -- Egy kis várakozás, sokat dolgozik ez a kód...
  DBMS_LOCK.SLEEP(10);
  -- A DBMS_LOCK csomag a SYS sémában van,
  -- használatához EXECUTE jog szükséges.
END csomag_inittel;
/


-- Csomagot hivatkozó eljárás

CREATE OR REPLACE PROCEDURE proc_csomag_inittel
IS
  -- Csomagolt típus hívatkozása
  v_Rec  csomag_inittel.t_rec;
  v2     csomag_inittel.v_Valtozo%type;
BEGIN
  -- Csomagolt konstans hívatkozása
  DBMS_OUTPUT.PUT_LINE('Csomag konstansa: ' || csomag_inittel.c_Konstans);
END proc_csomag_inittel;
/

-- Tesztek

-- Új munkamenet nyitása, hogy a csomag ne legyen inicializálva
CONNECT plsql/plsql
SET SERVEROUTPUT ON FORMAT WRAPPED;
-- Fordítás optimalizálással, majd futtatás
ALTER PROCEDURE proc_csomag_inittel COMPILE PLSQL_OPTIMIZE_LEVEL=2
  PLSQL_DEBUG=FALSE;

SET TIMING ON
EXEC proc_csomag_inittel;
-- Eltelt: 00:00:00.01
SET TIMING OFF;

-- Új munkamenet nyitása, hogy a csomag ne legyen inicializálva
CONNECT plsql/plsql
SET SERVEROUTPUT ON FORMAT WRAPPED;
-- Fordítás optimalizálás nélkül, majd futtatás
ALTER PROCEDURE proc_csomag_inittel COMPILE PLSQL_OPTIMIZE_LEVEL=0
  PLSQL_DEBUG=FALSE;

SET TIMING ON
EXEC proc_csomag_inittel;
-- Eltelt: 00:00:10.01
SET TIMING OFF;
