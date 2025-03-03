/* 
  Eml�kezz�nk vissza a tr_ugyfel_kolcsonzes_del
  trigger legut�bbi defin�ci�j�ra;

CREATE OR REPLACE TRIGGER tr_ugyfel_kolcsonzes_del
  INSTEAD OF DELETE ON NESTED TABLE konyvek OF ugyfel_kolcsonzes
  FOR EACH ROW
CALL konyvtar_csomag.visszahoz(:PARENT.id, :OLD.konyv_id)
/
*/

/*
  Ford�tsuk �jra a csomagot, amiben az elj�r�s,
  a trigger t�rzse van.
*/
ALTER PACKAGE konyvtar_csomag COMPILE;

/*
  A k�vetkez� DELETE hat�s�ra �jra lefordul a trigger.
*/
DELETE FROM TABLE(SELECT konyvek FROM ugyfel_kolcsonzes
                    WHERE id = 15)
  WHERE konyv_id = 15;
