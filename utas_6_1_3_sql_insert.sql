DECLARE
  v_Kolcsonzes  kolcsonzes%ROWTYPE;
BEGIN
  INSERT INTO kolcsonzes (kolcsonzo, konyv, datum)
    VALUES (15, 20, SYSDATE)
    RETURNING kolcsonzo, konyv, datum, hosszabbitva, megjegyzes
      INTO v_Kolcsonzes;

  -- rekord használata
  v_Kolcsonzes.kolcsonzo    := 20;
  v_Kolcsonzes.konyv        := 25;
  v_Kolcsonzes.datum        := SYSDATE;
  v_Kolcsonzes.hosszabbitva := 0;
  INSERT INTO kolcsonzes VALUES v_Kolcsonzes;
END;
/
