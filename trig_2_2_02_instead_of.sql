/* 
  Az INSTEAD OF triggerek haszn�lhat�k NESTED TABLE
  opci�val, egy n�zet kollekci�oszlop�nak m�dos�t�s�ra.
  NESTED TABLE el��r�s csak n�zetek eset�ben haszn�lhat�, 
  t�bl�k kollekci� t�pus� oszlopaira nem.

  Megadunk egy n�zetet, amely egy alk�rd�s eredm�ny�t
  kollekci� t�pus� oszlopk�nt mutatja.
*/
CREATE VIEW ugyfel_kolcsonzes AS
  SELECT u.id, u.nev, CAST( MULTISET( SELECT konyv, datum
                              FROM kolcsonzes
                              WHERE kolcsonzo = u.id)
                         AS T_Konyvek) AS konyvek
    FROM ugyfel u;

/*
  T�r�lj�k J�zsef Istv�n 'ECOOP 2001...' k�lcs�nz�s�t
*/
DELETE FROM TABLE(SELECT konyvek FROM ugyfel_kolcsonzes
                    WHERE id = 15)
  WHERE konyv_id = 25;
/*
DELETE FROM TABLE(SELECT konyvek FROM ugyfel_kolcsonzes
                                      *
Hiba a(z) 1. sorban:
ORA-25015: ezen a be�gyazott t�blan�zet oszlopon nem hajthat� v�gre DML
*/

/*
  A k�vetkez� trigger seg�ts�g�vel a visszahozatal
  adminisztr�c�ja automatiz�lhat� az ugyfel_kolcsonzes
  t�bla konyvek oszlop�n kereszt�l.

  Ugyanis egyetlen sor t�rl�se a be�gyazott t�bl�b�l
  el�id�zi a kolcsonzes t�bla egy sor�nak t�rl�s�t,
  az ugyfel t�bla konyvek oszlop�nak m�dos�t�s�t, valamint
  a konyv t�bla megfelel� bejegyz�s�nek v�ltoztat�s�t.
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
  T�r�lj�k J�zsef Istv�n 'ECOOP 2001...' k�lcs�nz�s�t
*/
DELETE FROM TABLE(SELECT konyvek FROM ugyfel_kolcsonzes
                    WHERE id = 15)
  WHERE konyv_id = 25;
/*
1 sor t�r�lve.
*/

/*
  A trigger v�grehajtott egy DELETE utas�t�st a kolcsonzes
  t�bl�n. Ellen�rizz�k, hogy a kor�bban l�trehozott
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
J�zsef Istv�n                  �br�k Katalin
02-�PR.  -10 06-J�N.  -23

(Megj.: Az eredm�ny form�tum�t kisebb m�ret�v� szabtuk �t
        az olvashat�s�g kedv��rt.)
*/
