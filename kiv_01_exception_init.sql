DECLARE
  i                  PLS_INTEGER;
  j                  NUMBER NOT NULL := 1;

  /* Egy névtelen hiba nevesítése. */
  numeric_overflow   EXCEPTION;
  PRAGMA EXCEPTION_INIT(numeric_overflow, -1426); -- numeric overflow

  /* Egy már amúgy is nevesített kivételhez még egy név rendelése. */
  VE_szinonima       EXCEPTION;
  PRAGMA EXCEPTION_INIT(VE_szinonima, -6502); -- VALUE_ERROR

BEGIN
  /* Kezeljük a numeric overflow hibát, PL/SQL-ben ehhez
     a hibához nincs elõre definiálva kivételnév. */
  <<blokk1>>
  BEGIN
    i := 2**32;
  EXCEPTION
    WHEN numeric_overflow THEN
      DBMS_OUTPUT.PUT_LINE('Blokk1 - numeric_overflow!' || SQLERRM);
  END blokk1;

  /* A VE_szinonima használható VALUE_ERROR helyett. */
  <<blokk2>>
  BEGIN
    i := NULL;
    j := i; -- VALUE_ERROR-t vált ki, mert i NULL.
    DBMS_OUTPUT.PUT_LINE(j);
  EXCEPTION
    WHEN VE_szinonima THEN
      DBMS_OUTPUT.PUT_LINE('Blokk2 - VALUE_ERROR: ' || SQLERRM);
  END blokk2;

  /* A VALUE_ERROR is használható VE_szinonima helyett. A két kivétel
     megegyezik. */
  <<blokk2>>
  BEGIN
    RAISE VE_szinonima;
  EXCEPTION
    WHEN VALUE_ERROR THEN -- A saját kivételünk szinonima a VALUE_ERROR-ra
      DBMS_OUTPUT.PUT_LINE('Blokk3 - VALUE_ERROR: ' || SQLERRM);
  END blokk1;

END;
/

/*
Eredmény:

Blokk1 - numeric_overflow!ORA-01426: numerikus túlcsordulás
Blokk2 - VALUE_ERROR: ORA-06502: PL/SQL: numerikus- vagy értékhiba ()
Blokk3 - VALUE_ERROR: ORA-06502: PL/SQL: numerikus- vagy értékhiba ()

A PL/SQL eljárás sikeresen befejezõdött.

*/
