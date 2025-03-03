/* While 1 - eredm�nye megegyezik Loop 2 eredm�ny�vel. Nincs kiv�tel. */
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
    || ' a legnagyobb, legfeljebb 5-jegy� faktori�lis.');
END;
/

/* While 2 - �res �s v�gtelen ciklus */
DECLARE
  i             PLS_INTEGER;
BEGIN
  i := 1;
  /* �res ciklus */
  WHILE i < 1 LOOP
    i := i + 1;
  END LOOP;

  /* V�gtelen ciklus */
  WHILE i < 60 LOOP
    i := (i + 1) MOD 60;
  END LOOP;
END;
/
