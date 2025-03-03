DECLARE
  TYPE t_vektor IS TABLE OF NUMBER
    INDEX BY BINARY_INTEGER;
  v_Vektor   t_vektor;
BEGIN
  FOR i IN -2..2 LOOP
    v_Vektor(i*2) := i;
  END LOOP;

  DBMS_OUTPUT.PUT_LINE('first: ' 
    || NVL(TO_CHAR(v_Vektor.FIRST), 'NULL')
    || ' last: ' || NVL(TO_CHAR(v_Vektor.LAST), 'NULL'));
END;
/

/*
Eredmény:

first: -4 last: 4

A PL/SQL eljárás sikeresen befejezõdött.
*/
