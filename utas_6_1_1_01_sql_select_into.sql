DECLARE
  v_Ugyfel      ugyfel%ROWTYPE;
  v_Id          ugyfel.id%TYPE;
  v_Info        VARCHAR2(100);
BEGIN
  SELECT * 
    INTO v_Ugyfel
    FROM ugyfel
    WHERE id = 15;

  SELECT id, SUBSTR(nev, 1, 40) || ' - ' || tel_szam
    INTO v_Id, v_Info
    FROM ugyfel
    WHERE id = 15;
END;
/
