/* 
  Emlékezzünk vissza a tr_ugyfel_kolcsonzes_del
  trigger legutóbbi definíciójára;

CREATE OR REPLACE TRIGGER tr_ugyfel_kolcsonzes_del
  INSTEAD OF DELETE ON NESTED TABLE konyvek OF ugyfel_kolcsonzes
  FOR EACH ROW
CALL konyvtar_csomag.visszahoz(:PARENT.id, :OLD.konyv_id)
/
*/

/*
  Fordítsuk újra a csomagot, amiben az eljárás,
  a trigger törzse van.
*/
ALTER PACKAGE konyvtar_csomag COMPILE;

/*
  A következõ DELETE hatására újra lefordul a trigger.
*/
DELETE FROM TABLE(SELECT konyvek FROM ugyfel_kolcsonzes
                    WHERE id = 15)
  WHERE konyv_id = 15;
