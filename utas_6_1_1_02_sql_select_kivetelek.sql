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
Eredm�ny:

DECLARE
*
Hiba a(z) 1. sorban:
ORA-01403: nem tal�lt adatot
ORA-06512: a(z) helyen a(z) 4. sorn�l
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
Eredm�ny:

DECLARE
*
Hiba a(z) 1. sorban:
ORA-01422: a pontos leh�v�s (FETCH) a k�v�ntn�l t�bb sorral t�r vissza
ORA-06512: a(z) helyen a(z) 4. sorn�l
*/
