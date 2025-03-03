DECLARE
  i    NUMBER;

  /* p �s j inicializ�l�sa minden h�v�skor megt�rt�nik. */
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
Eredm�ny:

 i  p  j
-- -- --
 1 -2  3
 2 -4  6

A PL/SQL elj�r�s sikeresen befejez�d�tt.
*/  
