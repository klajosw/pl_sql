DECLARE
  -- NOT NULL deklarációnál kötelezõ az értékadás
  v_Szam1       NUMBER NOT NULL := 10;

  -- v_Szam2 kezdõértéke NULL lesz
  v_Szam2       NUMBER;

BEGIN
  v_Szam1 := v_Szam2; -- VALUE_ERROR kivételt eredményez
END;
/
