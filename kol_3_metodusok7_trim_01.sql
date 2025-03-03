DECLARE
  v_Szerzok     T_Szerzok;
BEGIN
  v_Szerzok := T_Szerzok('Móricz Zsigmond', 'Móra Ferenc',
     'Ottlik Géza', 'Weöres Sándor');

  DBMS_OUTPUT.PUT_LINE('1. count: ' || v_Szerzok.COUNT);

  -- Törlünk egy elemet
  v_Szerzok.TRIM;
  DBMS_OUTPUT.PUT_LINE('2. count: ' || v_Szerzok.COUNT);

  -- Törlünk 2 elemet
  v_Szerzok.TRIM(2);
  DBMS_OUTPUT.PUT_LINE('3. count: ' || v_Szerzok.COUNT);

  BEGIN
    -- Megpróbálunk túl sok elemet törölni
    v_Szerzok.TRIM(10);
  EXCEPTION
    WHEN SUBSCRIPT_BEYOND_COUNT THEN
      DBMS_OUTPUT.PUT_LINE('Kivétel! ' || SQLERRM);
  END;

  DBMS_OUTPUT.PUT_LINE('4. count: ' || v_Szerzok.COUNT);

END;
/

/*
Eredmény:

1. count: 4
2. count: 3
3. count: 1
Kivétel! ORA-06533: Számlálón kívüli index érték
4. count: 1

A PL/SQL eljárás sikeresen befejezõdött.
*/
