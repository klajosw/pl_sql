DECLARE
  i    NUMBER;

  /* p és j inicializálása minden híváskor megtörténik. */
  PROCEDURE alprg(p NUMBER DEFAULT 2*(-i)) IS
    j    NUMBER := i*3;
  BEGIN
    DBMS_OUTPUT.PUT_LINE(' '|| i || ' ' || p || '  ' || j);
  END alprg;

BEGIN
  DBMS_OUTPUT.PUT_LINE(' i  p  j');
  DBMS_OUTPUT.PUT_LINE('-- -- --');
  i := 1;
  alprg;
  i := 2;
  alprg;
END;
/

/*
Eredmény:

 i  p  j
-- -- --
 1 -2  3
 2 -4  6

A PL/SQL eljárás sikeresen befejezõdött.
*/  
