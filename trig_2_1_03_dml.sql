/*
  A k�vetkez� trigger megakad�lyozza, hogy
  egy k�nyvet 2-n�l t�bbsz�r meghosszab�tsanak.

  Megjegyz�s:
  - A WHEN felt�tel�ben nem kell ':' az OLD, 
    NEW, PARENT el�.
  - Ugyanez a hat�s el�rhet� egy CHECK megszor�t�ssal.
*/
CREATE OR REPLACE TRIGGER tr_kolcsonzes_hosszabbit
  BEFORE INSERT OR UPDATE ON kolcsonzes
  FOR EACH ROW
  WHEN (NEW.hosszabbitva > 2 OR NEW.hosszabbitva < 0)
BEGIN
  RAISE_APPLICATION_ERROR(-20005,
    'Nem megengedett a hosszabb�t�sok sz�ma');
END tr_kolcsonzes_hosszabbit;
/
show errors

UPDATE kolcsonzes SET hosszabbitva = 10;
/*

UPDATE kolcsonzes SET hosszabbitva = 10
       *
Hiba a(z) 1. sorban:
ORA-20005: Nem megengedett a hosszabb�t�sok sz�ma
ORA-06512: a(z) "PLSQL.TR_KOLCSONZES_HOSSZABBIT", helyen a(z) 2. sorn�l
ORA-04088: hiba a(z) 'PLSQL.TR_KOLCSONZES_HOSSZABBIT' trigger fut�sa k�zben

*/
