
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
    a := 3+1;
    b := 3-2;
    c := b-a+1;
    d := b-a-1;   -- ismétlõdõ kifejezés elõfordulása
  END LOOP;
END proc_szamitas;
/
SHOW ERRORS;

-- Fordítás optimalizálással, majd futtatás
ALTER PROCEDURE proc_szamitas COMPILE PLSQL_OPTIMIZE_LEVEL=2
  PLSQL_DEBUG=FALSE;

SET TIMING ON
EXEC proc_szamitas(10000000);
-- Eltelt: 00:00:00.46
SET TIMING OFF;

-- Fordítás optimalizálás nélkül, majd futtatás
ALTER PROCEDURE proc_szamitas COMPILE PLSQL_OPTIMIZE_LEVEL=0
  PLSQL_DEBUG=FALSE;

SET TIMING ON
EXEC proc_szamitas(10000000);
-- Eltelt: 00:00:05.53
SET TIMING OFF;

