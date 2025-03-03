CREATE OR REPLACE PROCEDURE proc_indexes_kifejezes(
  p_Iter  PLS_INTEGER
) IS

  TYPE t_tab IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  v_Tab        t_tab;
  v_Index      NUMBER;
  v_Dummy      NUMBER;

  -- Tesztel�st seg�t� v�ltoz�k
  t                     NUMBER;
  t1                    NUMBER;
  t2                    NUMBER;
  v_Ures_ciklus_ideje   NUMBER;

  -- Tesztel�st seg�t� elj�r�sok
  PROCEDURE cimke(p_Cimke VARCHAR2) IS
  BEGIN
    DBMS_OUTPUT.PUT(RPAD(p_Cimke, 25));
  END cimke;

  PROCEDURE eltelt(
    p_Ures_ciklus  BOOLEAN DEFAULT FALSE
  ) IS
  BEGIN
    t := t2-t1;
    IF p_Ures_ciklus THEN
      v_Ures_ciklus_ideje := t;
    END IF;
    DBMS_OUTPUT.PUT_LINE('-  eltelt: ' || LPAD(t, 5)
        || ',  ciklusid� n�lk�l:' || LPAD((t-v_Ures_ciklus_ideje), 5));
  END eltelt;

-- Az elj�r�sblokk
BEGIN
  
  cimke('�res ciklus �rt�kad�ssal');
  t1 := DBMS_UTILITY.GET_TIME;
  FOR i IN 1..p_Iter
  LOOP
    v_Index := i-i; -- Egy �rt�kad�s
  END LOOP;
  t2 := DBMS_UTILITY.GET_TIME;
  eltelt(p_Ures_ciklus => true);

  cimke('V�ltoz� index');
  t1 := DBMS_UTILITY.GET_TIME;
  FOR i IN 1..p_Iter
  LOOP
    v_Index := i-i; -- Egy �rt�kad�s
    v_Tab(v_Index) := 10;
  END LOOP;
  t2 := DBMS_UTILITY.GET_TIME;
  eltelt;

  cimke('V�ltozatlan index');
  t1 := DBMS_UTILITY.GET_TIME;
  v_Index := 0;
  FOR i IN 1..p_Iter
  LOOP
    v_Dummy := i-i; -- Egy �rt�kad�s, hogy ugyanannyi k�d legyen.
    v_Tab(v_Index) := 10;
  END LOOP;
  t2 := DBMS_UTILITY.GET_TIME;
  eltelt;

END proc_indexes_kifejezes;
/
SHOW ERRORS;

SET SERVEROUTPUT ON FORMAT WRAPPED;

PROMPT 1. PLSQL_OPTIMIZE_LEVEL=2
-- Ford�t�s optimaliz�l�ssal, majd futtat�s
ALTER PROCEDURE proc_indexes_kifejezes COMPILE PLSQL_OPTIMIZE_LEVEL=2
  PLSQL_DEBUG=FALSE;
EXEC proc_indexes_kifejezes(2000000);


PROMPT 2. PLSQL_OPTIMIZE_LEVEL=0
-- Ford�t�s optimaliz�l�s n�lk�l, majd futtat�s
ALTER PROCEDURE proc_indexes_kifejezes COMPILE PLSQL_OPTIMIZE_LEVEL=0
  PLSQL_DEBUG=FALSE;
EXEC proc_indexes_kifejezes(2000000);

/*
  Egy tipikusnak mondhat� kimenet:

...
1. PLSQL_OPTIMIZE_LEVEL=2
Az elj�r�s m�dos�tva.

�res ciklus �rt�kad�ssal -  eltelt:    40,  ciklusid� n�lk�l:    0
V�ltoz� index            -  eltelt:   110,  ciklusid� n�lk�l:   70
V�ltozatlan index        -  eltelt:    83,  ciklusid� n�lk�l:   43

A PL/SQL elj�r�s sikeresen befejez�d�tt.


2. PLSQL_OPTIMIZE_LEVEL=0

Az elj�r�s m�dos�tva.

�res ciklus �rt�kad�ssal -  eltelt:    50,  ciklusid� n�lk�l:    0
V�ltoz� index            -  eltelt:   146,  ciklusid� n�lk�l:   96
V�ltozatlan index        -  eltelt:   148,  ciklusid� n�lk�l:   98

A PL/SQL elj�r�s sikeresen befejez�d�tt.

*/
