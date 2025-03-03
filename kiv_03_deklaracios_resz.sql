BEGIN

  DECLARE
    /* A k�vetkez� v�ltoz� inicializ�ci�ja sor�n 
       VALUE_ERROR kiv�tel v�lt�dik ki. */
       
    i   NUMBER(5) := 123456;

  BEGIN
    NULL;
  EXCEPTION
    WHEN VALUE_ERROR THEN
      /* Ez a kezel� nem tudja elkapni a deklar�ci�s
         r�szben bek�vetkezett kiv�telt. */
      DBMS_OUTPUT.PUT_LINE('bels�');
  END;

EXCEPTION
    WHEN VALUE_ERROR THEN
      /* Ez a kezel� kapja el a kiv�telt. */
      DBMS_OUTPUT.PUT_LINE('k�ls�');

END;
/

/*
Eredm�ny:

k�ls�

A PL/SQL elj�r�s sikeresen befejez�d�tt.
*/
