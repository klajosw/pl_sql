DECLARE
  -- NOT NULL deklar�ci�n�l k�telez� az �rt�kad�s
  v_Szam1       NUMBER NOT NULL := 10;

  -- v_Szam2 kezd��rt�ke NULL lesz
  v_Szam2       NUMBER;

BEGIN
  v_Szam1 := v_Szam2; -- VALUE_ERROR kiv�telt eredm�nyez
END;
/
