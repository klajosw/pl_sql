SET SERVEROUTPUT ON SIZE 10000;
/* Loop 1 - egy v�gtelen ciklus */
BEGIN
  LOOP
    DBMS_OUTPUT.PUT_LINE('Ez egy v�gtelen ciklus.');
    -- A DBMS_OUTPUT puffere szab csak hat�rt ennek a ciklusnak.
  END LOOP;
END;
/

/* Loop 2 - egy l�tsz�lag v�gtelen ciklus */
DECLARE
  v_Faktorialis NUMBER(5);
  i             PLS_INTEGER;
BEGIN
  i := 1;
  v_Faktorialis := 1;
  LOOP
    -- El�bb-ut�bb nem f�r el a szorzat 5 sz�mjegyen.
    v_Faktorialis := v_Faktorialis * i;
    i := i + 1;
  END LOOP;

EXCEPTION
  WHEN VALUE_ERROR THEN
    DBMS_OUTPUT.PUT_LINE(v_Faktorialis
      || ' a legnagyobb, legfeljebb 5-jegy� faktori�lis.');
END;
/
