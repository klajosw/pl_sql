CREATE OR REPLACE FUNCTION aktiv_kolcsonzo
RETURN NUMBER
AS
/* Megadja azon �gyfelek sz�m�t, akik jelenleg
   k�lcs�n�znek k�nyvet. */
  rv    NUMBER;
BEGIN
  SELECT COUNT(1) 
    INTO rv
    FROM (SELECT 1 FROM kolcsonzes GROUP BY kolcsonzo);

  RETURN rv;
END aktiv_kolcsonzo;
/
show errors

CREATE OR REPLACE FUNCTION osszes_kolcsonzo
RETURN NUMBER
AS
/* Megadja a beiratkozott �gyfelek sz�m�t. */
  rv    NUMBER;
BEGIN
  SELECT COUNT(1) 
    INTO rv
    FROM ugyfel;

  RETURN rv;
END osszes_kolcsonzo;
/
show errors
