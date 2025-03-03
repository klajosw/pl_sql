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
Eredmény:

P. Howard
Rejtõ Jenõ

A PL/SQL eljárás sikeresen befejezõdött.
*/
