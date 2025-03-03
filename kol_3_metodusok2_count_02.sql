DECLARE
  TYPE t_vektor IS TABLE OF NUMBER
    INDEX BY BINARY_INTEGER;
  v_Vektor   t_vektor;
BEGIN
  FOR i IN -2..2 LOOP
    v_Vektor(i*2) := i;
  END LOOP;

  DBMS_OUTPUT.PUT_LINE(v_Vektor.COUNT);
END;
/

/*
Eredmény:

5

A PL/SQL eljárás sikeresen befejezõdött.
*/
