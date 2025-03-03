CREATE OR REPLACE PROCEDURE proc_indexes_kifejezes(
  p_Iter  PLS_INTEGER
) IS

  TYPE t_tab IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  v_Tab        t_tab;
  v_Index      NUMBER;
  v_Dummy      NUMBER;

  -- Tesztelést segítõ változók
  t                     NUMBER;
  t1                    NUMBER;
  t2                    NUMBER;
  v_Ures_ciklus_ideje   NUMBER;

  -- Tesztelést segítõ eljárások
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
        || ',  ciklusidõ nélkül:' || LPAD((t-v_Ures_ciklus_ideje), 5));
  END eltelt;

-- Az eljárásblokk
BEGIN
  
  cimke('Üres ciklus értékadással');
  t1 := DBMS_UTILITY.GET_TIME;
  FOR i IN 1..p_Iter
  LOOP
    v_Index := i-i; -- Egy értékadás
  END LOOP;
  t2 := DBMS_UTILITY.GET_TIME;
  eltelt(p_Ures_ciklus => true);

  cimke('Változó index');
  t1 := DBMS_UTILITY.GET_TIME;
  FOR i IN 1..p_Iter
  LOOP
    v_Index := i-i; -- Egy értékadás
    v_Tab(v_Index) := 10;
  END LOOP;
  t2 := DBMS_UTILITY.GET_TIME;
  eltelt;

  cimke('Változatlan index');
  t1 := DBMS_UTILITY.GET_TIME;
  v_Index := 0;
  FOR i IN 1..p_Iter
  LOOP
    v_Dummy := i-i; -- Egy értékadás, hogy ugyanannyi kód legyen.
    v_Tab(v_Index) := 10;
  END LOOP;
  t2 := DBMS_UTILITY.GET_TIME;
  eltelt;

END proc_indexes_kifejezes;
/
SHOW ERRORS;

SET SERVEROUTPUT ON FORMAT WRAPPED;

PROMPT 1. PLSQL_OPTIMIZE_LEVEL=2
-- Fordítás optimalizálással, majd futtatás
ALTER PROCEDURE proc_indexes_kifejezes COMPILE PLSQL_OPTIMIZE_LEVEL=2
  PLSQL_DEBUG=FALSE;
EXEC proc_indexes_kifejezes(2000000);


PROMPT 2. PLSQL_OPTIMIZE_LEVEL=0
-- Fordítás optimalizálás nélkül, majd futtatás
ALTER PROCEDURE proc_indexes_kifejezes COMPILE PLSQL_OPTIMIZE_LEVEL=0
  PLSQL_DEBUG=FALSE;
EXEC proc_indexes_kifejezes(2000000);

/*
  Egy tipikusnak mondható kimenet:

...
1. PLSQL_OPTIMIZE_LEVEL=2
Az eljárás módosítva.

Üres ciklus értékadással -  eltelt:    40,  ciklusidõ nélkül:    0
Változó index            -  eltelt:   110,  ciklusidõ nélkül:   70
Változatlan index        -  eltelt:    83,  ciklusidõ nélkül:   43

A PL/SQL eljárás sikeresen befejezõdött.


2. PLSQL_OPTIMIZE_LEVEL=0

Az eljárás módosítva.

Üres ciklus értékadással -  eltelt:    50,  ciklusidõ nélkül:    0
Változó index            -  eltelt:   146,  ciklusidõ nélkül:   96
Változatlan index        -  eltelt:   148,  ciklusidõ nélkül:   98

A PL/SQL eljárás sikeresen befejezõdött.

*/
