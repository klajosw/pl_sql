DECLARE
  v_Konyvek     T_Konyvek := T_Konyvek();
BEGIN
  v_Konyvek.EXTEND(20);
  DBMS_OUTPUT.PUT_LINE('1. count: ' || v_Konyvek.COUNT);

  -- Törlünk pár elemet
  v_Konyvek.TRIM(5);
  DBMS_OUTPUT.PUT_LINE('2. count: ' || v_Konyvek.COUNT);
END;
/

/*
Eredmény:

1. count: 20
2. count: 15

A PL/SQL eljárás sikeresen befejezõdött.
*/
