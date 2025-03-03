/*
  Egy triggerrel megakad�lyozzuk azt, hogy valaki
  a kolcsonzes_naplo t�bl�b�l t�r�lj�n, vagy
  az ott lev� adatokat m�dos�tsa.

  Nincs sz�ks�g sorszint� triggerre, el�g
  utas�t�sszint� trigger.
*/
CREATE OR REPLACE TRIGGER tr_kolcsonzes_naplo_del_upd
  BEFORE DELETE OR UPDATE ON kolcsonzes_naplo
BEGIN
  RAISE_APPLICATION_ERROR(-20100,
    'Nem megengedett m�velet a kolcsonzes_naplo t�bl�n');
END tr_kolcsonzes_naplo_del_upd;
/
