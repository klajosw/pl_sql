/*
  Triggereink olvashat�bbak lehetnek, ha az 
  alap�rtelmezett NEW, OLD, illetve PARENT nevekre
  azok szemantik�j�nak megfelel� n�vvel hivatkozunk.
  Ezt a REFERENCING el��r�ssal adhatjuk meg.

  L�ssuk egy el�z� p�lda m�dos�tott v�ltozat�t:
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
  D�ntse el, melyik forma tetszik jobban,
  �s haszn�lja azt k�vetkezetesen!

  A k�nyv tov�bbi r�szeiben maradunk a 
  standard nevek mellett.
*/
