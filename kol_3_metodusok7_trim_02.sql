DECLARE
  v_Konyvek     T_Konyvek := T_Konyvek();
BEGIN
  v_Konyvek.EXTEND(20);
  DBMS_OUTPUT.PUT_LINE('1. count: ' || v_Konyvek.COUNT);

  -- T�rl�nk p�r elemet
  v_Konyvek.TRIM(5);
  DBMS_OUTPUT.PUT_LINE('2. count: ' || v_Konyvek.COUNT);
END;
/

/*
Eredm�ny:

1. count: 20
2. count: 15

A PL/SQL elj�r�s sikeresen befejez�d�tt.
*/
