
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
    d := b-a-1;   -- ism�tl�d� kifejez�s el�fordul�sa
  END LOOP;
END proc_szamitas;
/
SHOW ERRORS;

-- Ford�t�s optimaliz�l�ssal, majd futtat�s
ALTER PROCEDURE proc_szamitas COMPILE PLSQL_OPTIMIZE_LEVEL=2
  PLSQL_DEBUG=FALSE;

SET TIMING ON
EXEC proc_szamitas(10000000);
-- Eltelt: 00:00:03.06
SET TIMING OFF;

-- Ford�t�s optimaliz�l�s n�lk�l, majd futtat�s
ALTER PROCEDURE proc_szamitas COMPILE PLSQL_OPTIMIZE_LEVEL=0
  PLSQL_DEBUG=FALSE;

SET TIMING ON
EXEC proc_szamitas(10000000);
-- Eltelt: 00:00:05.54
SET TIMING OFF;

