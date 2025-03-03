/* 
  Az INSTEAD OF triggerek használhatók NESTED TABLE
  opcióval, egy nézet kollekcióoszlopának módosítására.
  NESTED TABLE elõírás csak nézetek esetében használható, 
  táblák kollekció típusú oszlopaira nem.

  Megadunk egy nézetet, amely egy alkérdés eredményét
  kollekció típusú oszlopként mutatja.
*/
CREATE VIEW ugyfel_kolcsonzes AS
  SELECT u.id, u.nev, CAST( MULTISET( SELECT konyv, datum
                              FROM kolcsonzes
                              WHERE kolcsonzo = u.id)
                         AS T_Konyvek) AS konyvek
    FROM ugyfel u;

/*
  Töröljük József István 'ECOOP 2001...' kölcsönzését
*/
DELETE FROM TABLE(SELECT konyvek FROM ugyfel_kolcsonzes
                    WHERE id = 15)
  WHERE konyv_id = 25;
/*
DELETE FROM TABLE(SELECT konyvek FROM ugyfel_kolcsonzes
                                      *
Hiba a(z) 1. sorban:
ORA-25015: ezen a beágyazott táblanézet oszlopon nem hajtható végre DML
*/

/*
  A következõ trigger segítségével a visszahozatal
  adminisztrácója automatizálható az ugyfel_kolcsonzes
  tábla konyvek oszlopán keresztül.

  Ugyanis egyetlen sor törlése a beágyazott táblából
  elõidézi a kolcsonzes tábla egy sorának törlését,
  az ugyfel tábla konyvek oszlopának módosítását, valamint
  a konyv tábla megfelelõ bejegyzésének változtatását.
*/
CREATE OR REPLACE TRIGGER tr_ugyfel_kolcsonzes_del
  INSTEAD OF DELETE ON NESTED TABLE konyvek OF ugyfel_kolcsonzes
  FOR EACH ROW
BEGIN
  DELETE FROM TABLE(SELECT konyvek FROM ugyfel
                 WHERE id = :PARENT.id)
    WHERE konyv_id = :OLD.konyv_id
      AND datum = :OLD.datum;

  DELETE FROM kolcsonzes
    WHERE kolcsonzo = :PARENT.id
      AND konyv = :OLD.konyv_id
      AND datum = :OLD.datum;

  UPDATE konyv SET szabad = szabad + 1
    WHERE id = :OLD.konyv_id;
END tr_ugyfel_kolcsonzes_del;
/
show errors

/*
  Töröljük József István 'ECOOP 2001...' kölcsönzését
*/
DELETE FROM TABLE(SELECT konyvek FROM ugyfel_kolcsonzes
                    WHERE id = 15)
  WHERE konyv_id = 25;
/*
1 sor törölve.
*/

/*
  A trigger végrehajtott egy DELETE utasítást a kolcsonzes
  táblán. Ellenõrizzük, hogy a korábban létrehozott
  tr_kolcsonzes_naploz trigger is lefutott-e?
*/
SELECT * FROM kolcsonzes_naplo;
/*
KONYV_ISBN                     KONYV_CIM           
------------------------------ ------------------------------
UGYFEL_NEV                     UGYFEL_ANYJANEVE
------------------------------ ------------------------------
ELVITTE      VISSZAHOZTA  MEGJEGYZES
------------ ------------ ---------------------
ISBN 963 03 9005 1             Java - start!
József István                  Ábrók Katalin
02-ÁPR.  -10 06-JÚN.  -23

(Megj.: Az eredmény formátumát kisebb méretûvé szabtuk át
        az olvashatóság kedvéért.)
*/
