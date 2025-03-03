DECLARE
  v_Szerzok     T_Szerzok;
  i             PLS_INTEGER;
BEGIN
  SELECT szerzo
    INTO v_Szerzok
    FROM konyv
    WHERE id = 15;
  
  i := 1;
  WHILE v_Szerzok.EXISTS(i) LOOP
    DBMS_OUTPUT.PUT_LINE(v_Szerzok(i));
    i := i+1;
  END LOOP;
END;
/

/*
Eredm�ny:

P. Howard
Rejt� Jen�

A PL/SQL elj�r�s sikeresen befejez�d�tt.
*/
