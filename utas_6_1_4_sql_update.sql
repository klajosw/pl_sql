DECLARE
  TYPE t_id_lista IS TABLE OF NUMBER;
  v_Id_lista    t_id_lista;

  v_Kolcsonzes  kolcsonzes%ROWTYPE;
BEGIN
  UPDATE TABLE(SELECT konyvek
                 FROM ugyfel
                 WHERE id = 20)
    SET datum = datum + 1
    RETURNING konyv_id BULK COLLECT INTO v_Id_lista;


  SELECT * 
    INTO v_Kolcsonzes
    FROM kolcsonzes
   WHERE kolcsonzo = 25 
     AND konyv     = 35;

  v_Kolcsonzes.datum        := v_Kolcsonzes.datum+1;
  v_Kolcsonzes.hosszabbitva := v_Kolcsonzes.hosszabbitva+1;

  -- rekord használata
  UPDATE kolcsonzes
     SET ROW = v_Kolcsonzes
   WHERE kolcsonzo = v_Kolcsonzes.kolcsonzo
     AND konyv     = v_Kolcsonzes.konyv;
END;
/
