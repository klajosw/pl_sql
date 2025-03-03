SELECT * FROM ugyfel, TABLE(konyvek);

SELECT * FROM TABLE(SELECT konyvek FROM ugyfel WHERE id = 15);

CREATE OR REPLACE FUNCTION fv_szerzok(p_Konyv konyv.id%TYPE)
RETURN T_Szerzok IS
  v_Szerzo   T_Szerzok;
BEGIN
  SELECT szerzo 
    INTO v_Szerzo
    FROM konyv
    WHERE id = p_Konyv;
  RETURN v_Szerzo;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN T_Szerzok();
END fv_szerzok;
/
show errors

SELECT * FROM TABLE(fv_szerzok(15));

SELECT * FROM TABLE(fv_szerzok(150));

BEGIN
  /* Ha skalár elemû kollekción végzünk el lekérdezést,
     akkor az egyetlen oszlop neve COLUMN_VALUE lesz. */
  FOR szerzo IN (
    SELECT * FROM TABLE(fv_szerzok(15))
  ) LOOP
    DBMS_OUTPUT.PUT_LINE(szerzo.COLUMN_VALUE);
  END LOOP;
END;
/
