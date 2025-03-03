DECLARE
  v_Szerzok     T_Szerzok := T_Szerzok();
BEGIN
  
  DBMS_OUTPUT.PUT_LINE('1. count: ' || v_Szerzok.COUNT
    || ' Limit: ' || NVL(TO_CHAR(v_Szerzok.LIMIT), 'NULL'));

  -- Egy NULL elemmel bõvítünk

  v_Szerzok.EXTEND;

  DBMS_OUTPUT.PUT_LINE('2. count: ' || v_Szerzok.COUNT
    || ' v_Szerzok(1): ' || NVL(v_Szerzok(1), 'NULL'));

  v_Szerzok(1) := 'Móra Ferenc';

  DBMS_OUTPUT.PUT_LINE('2. count: ' || v_Szerzok.COUNT
    || ' v_Szerzok(v_Szerzok.COUNT): '
    || NVL(v_Szerzok(v_Szerzok.COUNT), 'NULL'));

  -- 3 NULL elemmel bõvítünk
  v_Szerzok.EXTEND(3);

  DBMS_OUTPUT.PUT_LINE('2. count: ' || v_Szerzok.COUNT
    || ' v_Szerzok(v_Szerzok.COUNT): '
    || NVL(v_Szerzok(v_Szerzok.COUNT), 'NULL'));

  -- 4 elemmel bõvítünk, ezek értéke az 1. elem értékét veszik fel.
  v_Szerzok.EXTEND(4, 1);

  DBMS_OUTPUT.PUT_LINE('2. count: ' || v_Szerzok.COUNT
    || ' v_Szerzok(v_Szerzok.COUNT): '
    || NVL(v_Szerzok(v_Szerzok.COUNT), 'NULL'));

  BEGIN
    -- Megpróbljuk a dinamikus tömböt túlbõvíteni
    v_Szerzok.EXTEND(10);
  EXCEPTION
    WHEN SUBSCRIPT_OUTSIDE_LIMIT THEN
      DBMS_OUTPUT.PUT_LINE('Kivétel! ' || SQLERRM);
  END;

  DBMS_OUTPUT.NEW_LINE;
  FOR i IN 1..v_Szerzok.COUNT LOOP
    DBMS_OUTPUT.PUT_LINE(LPAD(i,2) || ' ' 
      || NVL(v_Szerzok(i), 'NULL'));
  END LOOP;
END;
/

/*
Eredmény:

1. count: 0 Limit: 10
2. count: 1 v_Szerzok(1): NULL
2. count: 1 v_Szerzok(v_Szerzok.COUNT): Móra Ferenc
2. count: 4 v_Szerzok(v_Szerzok.COUNT): NULL
2. count: 8 v_Szerzok(v_Szerzok.COUNT): Móra Ferenc
Kivétel! ORA-06532: Határon kívüli index

 1 Móra Ferenc
 2 NULL
 3 NULL
 4 NULL
 5 Móra Ferenc
 6 Móra Ferenc
 7 Móra Ferenc
 8 Móra Ferenc

A PL/SQL eljárás sikeresen befejezõdött.
*/
