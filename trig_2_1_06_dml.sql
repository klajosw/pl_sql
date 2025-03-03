/*
  Egy könyv azonosítóját kell megváltoztatni.
  Ez nem lehetséges automatikusan, mert
  a kolcsonzes tábla könyv oszlopa külsõ
  kulcs. Így azt is meg kell változtatni, hogy
  az integritási megszorítás ne sérüljön.

  A megszorítás a trigger futása után kerül ellenõrzésre.  
*/
CREATE OR REPLACE TRIGGER tr_konyv_id
  BEFORE UPDATE OF id ON konyv
  FOR EACH ROW
BEGIN
  -- Módosítjuk a kolcsonzes táblát
  UPDATE kolcsonzes SET konyv = :NEW.id
    WHERE konyv = :OLD.id;
END tr_konyv_id;
/
show errors;

UPDATE konyv SET id = 6 WHERE id = 5;
