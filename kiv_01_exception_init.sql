DECLARE
  i                  PLS_INTEGER;
  j                  NUMBER NOT NULL := 1;

  /* Egy n�vtelen hiba neves�t�se. */
  numeric_overflow   EXCEPTION;
  PRAGMA EXCEPTION_INIT(numeric_overflow, -1426); -- numeric overflow

  /* Egy m�r am�gy is neves�tett kiv�telhez m�g egy n�v rendel�se. */
  VE_szinonima       EXCEPTION;
  PRAGMA EXCEPTION_INIT(VE_szinonima, -6502); -- VALUE_ERROR

BEGIN
  /* Kezelj�k a numeric overflow hib�t, PL/SQL-ben ehhez
     a hib�hoz nincs el�re defini�lva kiv�teln�v. */
  <<blokk1>>
  BEGIN
    i := 2**32;
  EXCEPTION
    WHEN numeric_overflow THEN
      DBMS_OUTPUT.PUT_LINE('Blokk1 - numeric_overflow!' || SQLERRM);
  END blokk1;

  /* A VE_szinonima haszn�lhat� VALUE_ERROR helyett. */
  <<blokk2>>
  BEGIN
    i := NULL;
    j := i; -- VALUE_ERROR-t v�lt ki, mert i NULL.
    DBMS_OUTPUT.PUT_LINE(j);
  EXCEPTION
    WHEN VE_szinonima THEN
      DBMS_OUTPUT.PUT_LINE('Blokk2 - VALUE_ERROR: ' || SQLERRM);
  END blokk2;

  /* A VALUE_ERROR is haszn�lhat� VE_szinonima helyett. A k�t kiv�tel
     megegyezik. */
  <<blokk2>>
  BEGIN
    RAISE VE_szinonima;
  EXCEPTION
    WHEN VALUE_ERROR THEN -- A saj�t kiv�tel�nk szinonima a VALUE_ERROR-ra
      DBMS_OUTPUT.PUT_LINE('Blokk3 - VALUE_ERROR: ' || SQLERRM);
  END blokk1;

END;
/

/*
Eredm�ny:

Blokk1 - numeric_overflow!ORA-01426: numerikus t�lcsordul�s
Blokk2 - VALUE_ERROR: ORA-06502: PL/SQL: numerikus- vagy �rt�khiba ()
Blokk3 - VALUE_ERROR: ORA-06502: PL/SQL: numerikus- vagy �rt�khiba ()

A PL/SQL elj�r�s sikeresen befejez�d�tt.

*/
