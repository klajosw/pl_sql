/*
  Egy k�nyv azonos�t�j�t kell megv�ltoztatni.
  Ez nem lehets�ges automatikusan, mert
  a kolcsonzes t�bla k�nyv oszlopa k�ls�
  kulcs. �gy azt is meg kell v�ltoztatni, hogy
  az integrit�si megszor�t�s ne s�r�lj�n.

  A megszor�t�s a trigger fut�sa ut�n ker�l ellen�rz�sre.  
*/
CREATE OR REPLACE TRIGGER tr_konyv_id
  BEFORE UPDATE OF id ON konyv
  FOR EACH ROW
BEGIN
  -- M�dos�tjuk a kolcsonzes t�bl�t
  UPDATE kolcsonzes SET konyv = :NEW.id
    WHERE konyv = :OLD.id;
END tr_konyv_id;
/
show errors;

UPDATE konyv SET id = 6 WHERE id = 5;
