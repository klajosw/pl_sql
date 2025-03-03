DECLARE
  v_Szerzok     T_Szerzok;
  v_Konyvek     T_Konyvek;
BEGIN
  SELECT szerzo INTO v_Szerzok FROM konyv WHERE id = 15;
  SELECT konyvek INTO v_Konyvek FROM ugyfel WHERE id = 10;
  
  DBMS_OUTPUT.PUT_LINE('1. szerzo  count: ' || v_Szerzok.COUNT
    || ' Limit: ' || NVL(TO_CHAR(v_Szerzok.LIMIT), 'NULL'));

  DBMS_OUTPUT.PUT_LINE('2. konyvek count: ' || v_Konyvek.COUNT
    || ' Limit: ' || NVL(TO_CHAR(v_Konyvek.LIMIT), 'NULL'));
END;
/

/*
Eredmény:

1. szerzo  count: 2 Limit: 10
2. konyvek count: 3 Limit: NULL

A PL/SQL eljárás sikeresen befejezõdött.
*/
