DECLARE
  v_Szerzok     T_Szerzok;
BEGIN
  SELECT szerzo
    INTO v_Szerzok
    FROM konyv
    WHERE id = 15;
  
  FOR i IN 1..v_Szerzok.COUNT LOOP
    DBMS_OUTPUT.PUT_LINE(v_Szerzok(i));
  END LOOP;
END;
/

/*
Eredm�ny:

P. Howard
Rejt� Jen�

A PL/SQL elj�r�s sikeresen befejez�d�tt.
*/
