SET SERVEROUTPUT ON SIZE 10000;
/* Loop 1 - egy végtelen ciklus */
BEGIN
  LOOP
    DBMS_OUTPUT.PUT_LINE('Ez egy végtelen ciklus.');
    -- A DBMS_OUTPUT puffere szab csak határt ennek a ciklusnak.
  END LOOP;
END;
/

/* Loop 2 - egy látszólag végtelen ciklus */
DECLARE
  v_Faktorialis NUMBER(5);
  i             PLS_INTEGER;
BEGIN
  i := 1;
  v_Faktorialis := 1;
  LOOP
    -- Elõbb-utóbb nem fér el a szorzat 5 számjegyen.
    v_Faktorialis := v_Faktorialis * i;
    i := i + 1;
  END LOOP;

EXCEPTION
  WHEN VALUE_ERROR THEN
    DBMS_OUTPUT.PUT_LINE(v_Faktorialis
      || ' a legnagyobb, legfeljebb 5-jegyû faktoriális.');
END;
/
