CREATE OR REPLACE PROCEDURE proc_konstans(
  p_Iter  PLS_INTEGER
) IS
  c_Konstans   CONSTANT NUMBER := 98765;
  v_Konstans            NUMBER := 98765;

  v1                    NUMBER := 1;
  v2                    NUMBER;

  -- Tesztelést segítõ változók
  t                     NUMBER;
  t1                    NUMBER;
  t2                    NUMBER;
  v_Ures_ciklus_ideje   NUMBER;

  -- Eljárás esetleges mellékhatással
  PROCEDURE proc_lehet_mellekhatasa IS BEGIN NULL; END;

  -- Tesztelést segítõ eljárások
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
        || ',  ciklusidõ nélkül:' || LPAD((t-v_Ures_ciklus_ideje), 5));
  END eltelt;

-- Az eljárásblokk
BEGIN
  cimke('Üres ciklus');
  t1 := DBMS_UTILITY.GET_TIME;
  FOR i IN 1..p_Iter
  LOOP
    proc_lehet_mellekhatasa;
  END LOOP;
  t2 := DBMS_UTILITY.GET_TIME;
  eltelt(p_Ures_ciklus => TRUE);

  cimke('Változó használata');
  t1 := DBMS_UTILITY.GET_TIME;
  FOR i IN 1..p_Iter
  LOOP
    proc_lehet_mellekhatasa;
    v2 := v1 + v_Konstans * 12345;
  END LOOP;
  t2 := DBMS_UTILITY.GET_TIME;
  eltelt;

  cimke('Konstans használata');
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
-- Fordítás optimalizálással, majd futtatás
ALTER PROCEDURE proc_konstans COMPILE PLSQL_OPTIMIZE_LEVEL=2
  PLSQL_DEBUG=FALSE;
EXEC proc_konstans(2000000);


PROMPT 2. PLSQL_OPTIMIZE_LEVEL=0
-- Fordítás optimalizálás nélkül, majd futtatás
ALTER PROCEDURE proc_konstans COMPILE PLSQL_OPTIMIZE_LEVEL=0
  PLSQL_DEBUG=FALSE;
EXEC proc_konstans(2000000);

/*
  Egy tipikusnak mondható kimenet:

...

1. PLSQL_OPTIMIZE_LEVEL=2
Az eljárás módosítva.

Üres ciklus         -  eltelt:    78,  ciklusidõ nélkül:    0
Változó használata  -  eltelt:   186,  ciklusidõ nélkül:  108
Konstans használata -  eltelt:   117,  ciklusidõ nélkül:   39

A PL/SQL eljárás sikeresen befejezõdött.


2. PLSQL_OPTIMIZE_LEVEL=0
Az eljárás módosítva.

Üres ciklus         -  eltelt:    79,  ciklusidõ nélkül:    0
Változó használata  -  eltelt:   246,  ciklusidõ nélkül:  167
Konstans használata -  eltelt:   245,  ciklusidõ nélkül:  166

A PL/SQL eljárás sikeresen befejezõdött.

*/
