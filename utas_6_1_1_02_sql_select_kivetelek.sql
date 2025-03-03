DECLARE
  v_Ugyfel      ugyfel%ROWTYPE;
BEGIN
  SELECT * 
    INTO v_Ugyfel
    FROM ugyfel
    WHERE id = -1;
END;
/
/*
Eredmény:

DECLARE
*
Hiba a(z) 1. sorban:
ORA-01403: nem talált adatot
ORA-06512: a(z) helyen a(z) 4. sornál
*/

DECLARE
  v_Ugyfel      ugyfel%ROWTYPE;
BEGIN
  SELECT *
    INTO v_Ugyfel
    FROM ugyfel;
END;
/
/*
Eredmény:

DECLARE
*
Hiba a(z) 1. sorban:
ORA-01422: a pontos lehívás (FETCH) a kívántnál több sorral tér vissza
ORA-06512: a(z) helyen a(z) 4. sornál
*/
