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
Eredmény:

P. Howard
Rejtõ Jenõ

A PL/SQL eljárás sikeresen befejezõdött.
*/
