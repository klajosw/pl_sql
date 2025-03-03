DECLARE
  v_Datum         kolcsonzes.datum%TYPE;
  v_Hosszabbitva  kolcsonzes.hosszabbitva%TYPE;
BEGIN
  DELETE FROM kolcsonzes
    WHERE kolcsonzo = 15
      AND konyv = 20
    RETURNING datum, hosszabbitva 
      INTO  v_Datum, v_Hosszabbitva;
END;
/
