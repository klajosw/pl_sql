CREATE OR REPLACE PROCEDURE proc_konstans(
  p_Iter  PLS_INTEGER
) IS
  c_Konstans   CONSTANT NUMBER := 98765;
  v_Konstans            NUMBER := 98765;

  v1                    NUMBER := 1;
  v2                    NUMBER;

  -- Tesztel�st seg�t� v�ltoz�k
  t                     NUMBER;
  t1                    NUMBER;
  t2                    NUMBER;
  v_Ures_ciklus_ideje   NUMBER;

  -- Elj�r�s esetleges mell�khat�ssal
  PROCEDURE proc_lehet_mellekhatasa IS BEGIN NULL; END;

  -- Tesztel�st seg�t� elj�r�sok
  PROCEDURE cimke(p_Cimke VARCHAR2) IS
  BEGIN
    DBMS_OUTPUT.PUT(RPAD(p_Cimke, 20));
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
  cimke('�res ciklus');
  t1 := DBMS_UTILITY.GET_TIME;
  FOR i IN 1..p_Iter
  LOOP
    proc_lehet_mellekhatasa;
  END LOOP;
  t2 := DBMS_UTILITY.GET_TIME;
  eltelt(p_Ures_ciklus => TRUE);

  cimke('V�ltoz� haszn�lata');
  t1 := DBMS_UTILITY.GET_TIME;
  FOR i IN 1..p_Iter
  LOOP
    proc_lehet_mellekhatasa;
    v2 := v1 + v_Konstans * 12345;
  END LOOP;
  t2 := DBMS_UTILITY.GET_TIME;
  eltelt;

  cimke('Konstans haszn�lata');
  t1 := DBMS_UTILITY.GET_TIME;
  FOR i IN 1..p_Iter
  LOOP
    proc_lehet_mellekhatasa;
    v2 := v1 + c_Konstans * 12345;
  END LOOP;
  t2 := DBMS_UTILITY.GET_TIME;
  eltelt;

END proc_konstans;
/
SHOW ERRORS;

SET SERVEROUTPUT ON FORMAT WRAPPED;

PROMPT 1. PLSQL_OPTIMIZE_LEVEL=2
-- Ford�t�s optimaliz�l�ssal, majd futtat�s
ALTER PROCEDURE proc_konstans COMPILE PLSQL_OPTIMIZE_LEVEL=2
  PLSQL_DEBUG=FALSE;
EXEC proc_konstans(2000000);


PROMPT 2. PLSQL_OPTIMIZE_LEVEL=0
-- Ford�t�s optimaliz�l�s n�lk�l, majd futtat�s
ALTER PROCEDURE proc_konstans COMPILE PLSQL_OPTIMIZE_LEVEL=0
  PLSQL_DEBUG=FALSE;
EXEC proc_konstans(2000000);

/*
  Egy tipikusnak mondhat� kimenet:

...

1. PLSQL_OPTIMIZE_LEVEL=2
Az elj�r�s m�dos�tva.

�res ciklus         -  eltelt:    78,  ciklusid� n�lk�l:    0
V�ltoz� haszn�lata  -  eltelt:   186,  ciklusid� n�lk�l:  108
Konstans haszn�lata -  eltelt:   117,  ciklusid� n�lk�l:   39

A PL/SQL elj�r�s sikeresen befejez�d�tt.


2. PLSQL_OPTIMIZE_LEVEL=0
Az elj�r�s m�dos�tva.

�res ciklus         -  eltelt:    79,  ciklusid� n�lk�l:    0
V�ltoz� haszn�lata  -  eltelt:   246,  ciklusid� n�lk�l:  167
Konstans haszn�lata -  eltelt:   245,  ciklusid� n�lk�l:  166

A PL/SQL elj�r�s sikeresen befejez�d�tt.

*/
