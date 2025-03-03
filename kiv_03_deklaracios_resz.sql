BEGIN

  DECLARE
    /* A következõ változó inicializációja során 
       VALUE_ERROR kivétel váltódik ki. */
       
    i   NUMBER(5) := 123456;

  BEGIN
    NULL;
  EXCEPTION
    WHEN VALUE_ERROR THEN
      /* Ez a kezelõ nem tudja elkapni a deklarációs
         részben bekövetkezett kivételt. */
      DBMS_OUTPUT.PUT_LINE('belsõ');
  END;

EXCEPTION
    WHEN VALUE_ERROR THEN
      /* Ez a kezelõ kapja el a kivételt. */
      DBMS_OUTPUT.PUT_LINE('külsõ');

END;
/

/*
Eredmény:

külsõ

A PL/SQL eljárás sikeresen befejezõdött.
*/
