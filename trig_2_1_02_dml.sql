/*
  A következõ trigger segítségével naplózzuk
  a törölt kölcsönzéseket a kolcsonzes_naplo táblában.
*/
CREATE OR REPLACE TRIGGER tr_kolcsonzes_naploz
  AFTER DELETE ON kolcsonzes
  REFERENCING OLD AS kolcsonzes
  FOR EACH ROW
DECLARE
  v_Konyv    konyv%ROWTYPE;
  v_Ugyfel   ugyfel%ROWTYPE;
BEGIN
  SELECT * INTO v_Ugyfel
    FROM ugyfel WHERE id = :kolcsonzes.kolcsonzo;

  SELECT * INTO v_Konyv
    FROM konyv WHERE id = :kolcsonzes.konyv;

  INSERT INTO kolcsonzes_naplo VALUES(
    v_Konyv.ISBN, v_Konyv.cim,
    v_Ugyfel.nev, v_Ugyfel.anyja_neve,
    :kolcsonzes.datum, SYSDATE, 
    :kolcsonzes.megjegyzes);
END tr_kolcsonzes_naploz;
/
show errors
