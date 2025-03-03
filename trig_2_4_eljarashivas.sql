/*
  Az el�z�ek sor�n l�trehozott 
  tr_ugyfel_kolcsonzes_del egy k�nyv visszahozatal�t
  adminisztr�lta. Ugyanezt a funkci�t m�r meg�rtuk
  egy csomagbeli elj�r�ssal.
  C�lszer�bb lenne azt haszn�lni, a k�d
  �jrahaszn�l�sa v�gett.
*/
CREATE OR REPLACE TRIGGER tr_ugyfel_kolcsonzes_del
  INSTEAD OF DELETE ON NESTED TABLE konyvek OF ugyfel_kolcsonzes
  FOR EACH ROW
CALL konyvtar_csomag.visszahoz(:PARENT.id, :OLD.konyv_id)
/
