DECLARE
  TYPE t_vektor IS TABLE OF NUMBER
    INDEX BY BINARY_INTEGER;
  v_Vektor   t_vektor;
  i          PLS_INTEGER;
BEGIN
  FOR i IN -2..2 LOOP
    v_Vektor(i*2) := i;
  END LOOP;

  i := v_Vektor.FIRST;
  WHILE i IS NOT NULL LOOP
    DBMS_OUTPUT.PUT_LINE(LPAD(i,2) || ' ' 
      || LPAD(v_Vektor(i), 2));
    i := v_Vektor.NEXT(i);
  END LOOP;

  DBMS_OUTPUT.NEW_LINE;

  i := v_Vektor.LAST;
  WHILE i IS NOT NULL LOOP
    DBMS_OUTPUT.PUT_LINE(LPAD(i,2) || ' ' 
      || LPAD(v_Vektor(i), 2));
    i := v_Vektor.PRIOR(i);
  END LOOP;
END;
/

/*
Eredmény:

-4 -2
-2 -1
 0  0
 2  1
 4  2

 4  2
 2  1
 0  0
-2 -1
-4 -2

A PL/SQL eljárás sikeresen befejezõdött.
*/
