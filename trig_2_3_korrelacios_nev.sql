/*
  Triggereink olvashatóbbak lehetnek, ha az 
  alapértelmezett NEW, OLD, illetve PARENT nevekre
  azok szemantikájának megfelelõ névvel hivatkozunk.
  Ezt a REFERENCING elõírással adhatjuk meg.

  Lássuk egy elõzõ példa módosított változatát:
*/
CREATE OR REPLACE TRIGGER tr_ugyfel_kolcsonzes_del
  INSTEAD OF DELETE ON NESTED TABLE konyvek OF ugyfel_kolcsonzes
  REFERENCING OLD AS v_Kolcsonzes
    PARENT AS v_Ugyfel
  FOR EACH ROW
BEGIN
  DELETE FROM TABLE(SELECT konyvek FROM ugyfel
                 WHERE id = :v_Ugyfel.id)
    WHERE konyv_id = :v_Kolcsonzes.konyv_id
      AND datum = :v_Kolcsonzes.datum;

  DELETE FROM kolcsonzes
    WHERE kolcsonzo = :v_Ugyfel.id
      AND konyv = :v_Kolcsonzes.konyv_id
      AND datum = :v_Kolcsonzes.datum;

  UPDATE konyv SET szabad = szabad + 1
    WHERE id = :v_Kolcsonzes.konyv_id;
END tr_ugyfel_kolcsonzes_del;
/
show errors

/*
  Döntse el, melyik forma tetszik jobban,
  és használja azt következetesen!

  A könyv további részeiben maradunk a 
  standard nevek mellett.
*/
