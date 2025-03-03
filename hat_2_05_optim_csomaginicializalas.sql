-- Csomag inicializ�l�ssal �s az inicializ�l�st�l nem f�gg� tagokkal

CREATE OR REPLACE PACKAGE csomag_inittel
IS
  -- N�h�ny csomagolt elem
  c_Konstans CONSTANT  NUMBER := 10;
  v_Valtozo            NUMBER := 10;
  TYPE t_rec IS RECORD (id NUMBER, nev VARCHAR2(10000));

END csomag_inittel;
/

CREATE OR REPLACE PACKAGE BODY csomag_inittel
IS
-- Csomaginicializ�l� blokk
BEGIN
  DBMS_OUTPUT.PUT_LINE('Csomaginicializ�l� blokk.');
  -- Egy kis v�rakoz�s, sokat dolgozik ez a k�d...
  DBMS_LOCK.SLEEP(10);
  -- A DBMS_LOCK csomag a SYS s�m�ban van,
  -- haszn�lat�hoz EXECUTE jog sz�ks�ges.
END csomag_inittel;
/


-- Csomagot hivatkoz� elj�r�s

CREATE OR REPLACE PROCEDURE proc_csomag_inittel
IS
  -- Csomagolt t�pus h�vatkoz�sa
  v_Rec  csomag_inittel.t_rec;
  v2     csomag_inittel.v_Valtozo%type;
BEGIN
  -- Csomagolt konstans h�vatkoz�sa
  DBMS_OUTPUT.PUT_LINE('Csomag konstansa: ' || csomag_inittel.c_Konstans);
END proc_csomag_inittel;
/

-- Tesztek

-- �j munkamenet nyit�sa, hogy a csomag ne legyen inicializ�lva
CONNECT plsql/plsql
SET SERVEROUTPUT ON FORMAT WRAPPED;
-- Ford�t�s optimaliz�l�ssal, majd futtat�s
ALTER PROCEDURE proc_csomag_inittel COMPILE PLSQL_OPTIMIZE_LEVEL=2
  PLSQL_DEBUG=FALSE;

SET TIMING ON
EXEC proc_csomag_inittel;
-- Eltelt: 00:00:00.01
SET TIMING OFF;

-- �j munkamenet nyit�sa, hogy a csomag ne legyen inicializ�lva
CONNECT plsql/plsql
SET SERVEROUTPUT ON FORMAT WRAPPED;
-- Ford�t�s optimaliz�l�s n�lk�l, majd futtat�s
ALTER PROCEDURE proc_csomag_inittel COMPILE PLSQL_OPTIMIZE_LEVEL=0
  PLSQL_DEBUG=FALSE;

SET TIMING ON
EXEC proc_csomag_inittel;
-- Eltelt: 00:00:10.01
SET TIMING OFF;
