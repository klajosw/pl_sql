/* While 1 - eredménye megegyezik Loop 2 eredményével. Nincs kivétel. */
DECLARE
  v_Faktorialis NUMBER(5);
  i             PLS_INTEGER;
BEGIN
  i := 1;
  v_Faktorialis := 1;
  WHILE v_Faktorialis * i < 10**5 LOOP
    v_Faktorialis := v_Faktorialis * i;
    i := i + 1;
  END LOOP;

  DBMS_OUTPUT.PUT_LINE(v_Faktorialis
    || ' a legnagyobb, legfeljebb 5-jegyû faktoriális.');
END;
/

/* While 2 - üres és végtelen ciklus */
DECLARE
  i             PLS_INTEGER;
BEGIN
  i := 1;
  /* Üres ciklus */
  WHILE i < 1 LOOP
    i := i + 1;
  END LOOP;

  /* Végtelen ciklus */
  WHILE i < 60 LOOP
    i := (i + 1) MOD 60;
  END LOOP;
END;
/
