DECLARE
  v_Szerzok     T_Szerzok;
  j             PLS_INTEGER;
BEGIN
  BEGIN
    j := v_Szerzok.FIRST;
  EXCEPTION
    WHEN COLLECTION_IS_NULL THEN
      DBMS_OUTPUT.PUT_LINE('Kivétel! ' || SQLERRM);
  END;

  v_Szerzok := T_Szerzok();
  DBMS_OUTPUT.PUT_LINE('first: ' 
    || NVL(TO_CHAR(v_Szerzok.FIRST), 'NULL')
    || ' last: ' || NVL(TO_CHAR(v_Szerzok.LAST), 'NULL'));

  DBMS_OUTPUT.NEW_LINE;
  SELECT szerzo
    INTO v_Szerzok
    FROM konyv
    WHERE id = 15;
  
  FOR i IN v_Szerzok.FIRST..v_Szerzok.LAST LOOP
    DBMS_OUTPUT.PUT_LINE(v_Szerzok(i));
  END LOOP;
END;
/

/*
Eredmény:
Kivétel! ORA-06531: Inicializálatlan gyûjtõre való hivatkozás
first: NULL last: NULL

P. Howard
Rejtõ Jenõ

A PL/SQL eljárás sikeresen befejezõdött.
*/
