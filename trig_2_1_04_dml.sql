/*
  Egy triggerrel megakadályozzuk azt, hogy valaki
  a kolcsonzes_naplo táblából töröljön, vagy
  az ott levõ adatokat módosítsa.

  Nincs szükség sorszintû triggerre, elég
  utasításszintû trigger.
*/
CREATE OR REPLACE TRIGGER tr_kolcsonzes_naplo_del_upd
  BEFORE DELETE OR UPDATE ON kolcsonzes_naplo
BEGIN
  RAISE_APPLICATION_ERROR(-20100,
    'Nem megengedett mûvelet a kolcsonzes_naplo táblán');
END tr_kolcsonzes_naplo_del_upd;
/
