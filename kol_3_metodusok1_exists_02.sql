DECLARE
  TYPE t_vektor IS TABLE OF NUMBER
    INDEX BY BINARY_INTEGER;
  v_Vektor   t_vektor;
BEGIN
  FOR i IN -2..2 LOOP
    v_Vektor(i*2) := i;
  END LOOP;

  FOR i IN -5..5 LOOP
    IF v_Vektor.EXISTS(i) THEN
      DBMS_OUTPUT.PUT_LINE(LPAD(i,2) || ' ' 
        || LPAD(v_Vektor(i), 2));
    END IF;
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

A PL/SQL eljárás sikeresen befejezõdött.
*/
