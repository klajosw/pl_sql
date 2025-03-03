/*
CONNECT system/...@db10gr2;
ALTER SYSTEM SET PLSQL_NATIVE_LIBRARY_DIR='/oracle/oradata/db10gr2/nat_lib/';

CONNECT plsql/...@db10gr2
*/
CREATE OR REPLACE PROCEDURE proc_szamitas(
  p_Iter  PLS_INTEGER
) IS

  a PLS_INTEGER; 
  b PLS_INTEGER; 
  c PLS_INTEGER; 
  d PLS_INTEGER; 

BEGIN
  FOR i IN 1..p_Iter
  LOOP
    a := i+1;
    b := i-2;
    c := b-a+1;
    d := b-a-1;   -- ismétlõdõ kifejezés elõfordulása
  END LOOP;
END proc_szamitas;
/
SHOW ERRORS;

-- Fordítás optimalizálással, majd futtatás
ALTER PROCEDURE proc_szamitas COMPILE 
  PLSQL_DEBUG=FALSE
  PLSQL_CODE_TYPE=INTERPRETED
  PLSQL_OPTIMIZE_LEVEL=2
;
SET TIMING ON
EXEC proc_szamitas(10000000);
SET TIMING OFF;

-- Fordítás optimalizálással, majd futtatás
ALTER PROCEDURE proc_szamitas COMPILE 
  PLSQL_DEBUG=FALSE
  PLSQL_CODE_TYPE=NATIVE
  PLSQL_OPTIMIZE_LEVEL=2
;
SET TIMING ON
EXEC proc_szamitas(10000000);
SET TIMING OFF;

-- Fordítás optimalizálás nélkül, majd futtatás
ALTER PROCEDURE proc_szamitas COMPILE
  PLSQL_DEBUG=FALSE
  PLSQL_CODE_TYPE=INTERPRETED
  PLSQL_OPTIMIZE_LEVEL=0
;
SET TIMING ON
EXEC proc_szamitas(10000000);
SET TIMING OFF;

-- Fordítás optimalizálás nélkül, majd futtatás
ALTER PROCEDURE proc_szamitas COMPILE
  PLSQL_DEBUG=FALSE
  PLSQL_CODE_TYPE=NATIVE
  PLSQL_OPTIMIZE_LEVEL=0
;
SET TIMING ON
EXEC proc_szamitas(10000000);
SET TIMING OFF;

/*
2I - PLSQL_OPTIMIZE_LEVEL=2  PLSQL_CODE_TYPE=INTERPRETED
Eltelt: 00:00:03.05

2N - PLSQL_OPTIMIZE_LEVEL=2  PLSQL_CODE_TYPE=NATIVE
Eltelt: 00:00:01.82

0I - PLSQL_OPTIMIZE_LEVEL=0  PLSQL_CODE_TYPE=INTERPRETED
Eltelt: 00:00:05.78

0N - PLSQL_OPTIMIZE_LEVEL=0  PLSQL_CODE_TYPE=NATIVE
Eltelt: 00:00:03.33
*/
