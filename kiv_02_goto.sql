DECLARE
  a   NUMBER NOT NULL := 1;
  b   NUMBER;

BEGIN
  <<tartalmazo>>
  BEGIN
    <<vissza>>
    a := b; -- VALUE_ERRORt v�lt ki, mert b NULL
  EXCEPTION
    WHEN VALUE_ERROR THEN
      b := 1; -- Hogy legk�zelebb b ne legyen NULL;
      -- GOTO vissza;  -- ford�t�si hib�t eredm�nyezne
      GOTO tartalmazo; -- k�ls� blokk cimk�j�re ugorhatunk
  END;
END;
/
