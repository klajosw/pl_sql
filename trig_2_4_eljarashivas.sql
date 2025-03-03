/*
  Az elõzõek során létrehozott 
  tr_ugyfel_kolcsonzes_del egy könyv visszahozatalát
  adminisztrálta. Ugyanezt a funkciót már megírtuk
  egy csomagbeli eljárással.
  Célszerûbb lenne azt használni, a kód
  újrahasználása végett.
*/
CREATE OR REPLACE TRIGGER tr_ugyfel_kolcsonzes_del
  INSTEAD OF DELETE ON NESTED TABLE konyvek OF ugyfel_kolcsonzes
  FOR EACH ROW
CALL konyvtar_csomag.visszahoz(:PARENT.id, :OLD.konyv_id)
/
