/*
  Letiltjuk azt a triggert, amelyik lehet�v� teszi
  az ugyfel_kolcsonzes n�zet konyvek oszlop�nak m�dos�t�s�t.
*/
ALTER TRIGGER tr_ugyfel_kolcsonzes_del DISABLE;

DELETE FROM TABLE(SELECT konyvek FROM ugyfel_kolcsonzes
                    WHERE id = 15)
  WHERE konyv_id = 45;
/*
DELETE FROM TABLE(SELECT konyvek FROM ugyfel_kolcsonzes
                                      *
Hiba a(z) 1. sorban:
ORA-25015: ezen a be�gyazott t�blan�zet oszlopon nem hajthat� v�gre DML
*/

-- �jra enged�lyezz�k a triggert.
ALTER TRIGGER tr_ugyfel_kolcsonzes_del ENABLE;

-- Explicit m�don �jraford�tjuk a r�gi be�ll�t�sokkal
ALTER TRIGGER tr_ugyfel_kolcsonzes_del COMPILE REUSE SETTINGS;

-- �t is nevezhetj�k:
ALTER TRIGGER tr_ugyfel_kolcsonzes_del RENAME TO tr_ugyf_kolcs_del;
