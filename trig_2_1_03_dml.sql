/*
  A következõ trigger megakadályozza, hogy
  egy könyvet 2-nél többször meghosszabítsanak.

  Megjegyzés:
  - A WHEN feltételében nem kell ':' az OLD, 
    NEW, PARENT elé.
  - Ugyanez a hatás elérhetõ egy CHECK megszorítással.
*/
CREATE OR REPLACE TRIGGER tr_kolcsonzes_hosszabbit
  BEFORE INSERT OR UPDATE ON kolcsonzes
  FOR EACH ROW
  WHEN (NEW.hosszabbitva > 2 OR NEW.hosszabbitva < 0)
BEGIN
  RAISE_APPLICATION_ERROR(-20005,
    'Nem megengedett a hosszabbítások száma');
END tr_kolcsonzes_hosszabbit;
/
show errors

UPDATE kolcsonzes SET hosszabbitva = 10;
/*

UPDATE kolcsonzes SET hosszabbitva = 10
       *
Hiba a(z) 1. sorban:
ORA-20005: Nem megengedett a hosszabbítások száma
ORA-06512: a(z) "PLSQL.TR_KOLCSONZES_HOSSZABBIT", helyen a(z) 2. sornál
ORA-04088: hiba a(z) 'PLSQL.TR_KOLCSONZES_HOSSZABBIT' trigger futása közben

*/
