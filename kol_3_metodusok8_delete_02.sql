DECLARE
  TYPE t_vektor IS TABLE OF NUMBER
    INDEX BY BINARY_INTEGER;
  v_Vektor      t_vektor;
BEGIN
  FOR i IN -2..2 LOOP
    v_Vektor(i*2) := i;
  END LOOP;
  DBMS_OUTPUT.PUT_LINE('1. count: ' || v_Vektor.COUNT);

  -- Hány tényleges elem esik ebbe az intervallumba?
  v_Vektor.DELETE(-1, 2);
  DBMS_OUTPUT.PUT_LINE('2. count: ' || v_Vektor.COUNT);
END;
/

/*
Eredmény:

1. count: 5
2. count: 3

A PL/SQL eljárás sikeresen befejezõdött.
*/
