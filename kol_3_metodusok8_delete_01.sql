DECLARE
  TYPE t_nevek IS TABLE OF VARCHAR2(10);
  v_Nevek    t_nevek := t_nevek('A1', 'B2', 'C3',
    'D4', 'E5', 'F6', 'G7', 'H8', 'I9', 'J10');
  i          PLS_INTEGER;
BEGIN
  DBMS_OUTPUT.PUT_LINE('1. count: ' || v_Nevek.COUNT);

  -- Törlünk pár elemet
  v_Nevek.DELETE(3);
  v_Nevek.DELETE(6, 8);

  -- Gond nélkül megy ez is
  v_Nevek.DELETE(10, 12);
  v_Nevek.DELETE(60);

  DBMS_OUTPUT.PUT_LINE('2. count: ' || v_Nevek.COUNT);

  DBMS_OUTPUT.NEW_LINE;
  i := v_Nevek.FIRST;
  WHILE i IS NOT NULL LOOP
    DBMS_OUTPUT.PUT_LINE(LPAD(i,2) || ' ' 
      || LPAD(v_Nevek(i), 2));
    i := v_Nevek.NEXT(i);
  END LOOP;
END;
/

/*
Eredmény:

1. count: 10
2. count: 5

 1 A1
 2 B2
 4 D4
 5 E5
 9 I9

A PL/SQL eljárás sikeresen befejezõdött.
*/
