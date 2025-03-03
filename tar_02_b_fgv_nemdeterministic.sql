CREATE OR REPLACE FUNCTION aktiv_kolcsonzo
RETURN NUMBER
AS
/* Megadja azon ügyfelek számát, akik jelenleg
   kölcsönöznek könyvet. */
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
/* Megadja a beiratkozott ügyfelek számát. */
  rv    NUMBER;
BEGIN
  SELECT COUNT(1) 
    INTO rv
    FROM ugyfel;

  RETURN rv;
END osszes_kolcsonzo;
/
show errors
