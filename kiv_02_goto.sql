DECLARE
  a   NUMBER NOT NULL := 1;
  b   NUMBER;

BEGIN
  <<tartalmazo>>
  BEGIN
    <<vissza>>
    a := b; -- VALUE_ERRORt vált ki, mert b NULL
  EXCEPTION
    WHEN VALUE_ERROR THEN
      b := 1; -- Hogy legközelebb b ne legyen NULL;
      -- GOTO vissza;  -- fordítási hibát eredményezne
      GOTO tartalmazo; -- külsõ blokk cimkéjére ugorhatunk
  END;
END;
/
