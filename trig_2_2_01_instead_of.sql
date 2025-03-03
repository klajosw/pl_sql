/*
  Az INSTEAD OF triggerek lehet�v� teszik n�zetek m�dos�t�s�t.  

  Megpr�b�ljuk m�dos�tani egy �gyf�l nev�t az ugyfel_konyv
  n�zet sorain kereszt�l.
*/
UPDATE ugyfel_konyv SET ugyfel = 'J�zsef Istv�n TRIGGERES' 
  WHERE ugyfel_id = 15;
/*
UPDATE ugyfel_konyv SET ugyfel = 'J�zsef Istv�n TRIGGERES' 
                        *
Hiba a(z) 1. sorban:
ORA-01779: nem m�dos�that� olyan oszlop, amely egy kulcsot nem meg�rz� t�bl�ra utal
*/

/*
  A k�vetkez� trigger seg�ts�g�vel egy �gyf�l nev�t, vagy
  egy k�nyv c�m�t m�dos�thatjuk az ugyfel_konyv n�zeten
  kereszt�l. Ha azonos�t�t is megpr�b�lnak v�ltoztatni
  azzal egyszer�en nem t�r�d�nk (nem v�ltunk ki kiv�telt).
*/
CREATE OR REPLACE TRIGGER tr_ugyfel_konyv_mod
  INSTEAD OF UPDATE ON ugyfel_konyv
  FOR EACH ROW
BEGIN
  IF :NEW.ugyfel <> :OLD.ugyfel THEN
    UPDATE ugyfel SET nev = :NEW.ugyfel
      WHERE id = :OLD.ugyfel_id;
  END IF;

  IF :NEW.konyv <> :OLD.konyv THEN
    UPDATE konyv SET cim = :NEW.konyv
      WHERE id = :OLD.konyv_id;
  END IF;
END tr_ugyfel_konyv_mod;
/
show errors

/*
  Megpr�b�lunk m�dos�tani megint.
*/
UPDATE ugyfel_konyv SET ugyfel = 'J�zsef Istv�n TRIGGERES' 
  WHERE ugyfel_id = 15;
/*
5 sor m�dos�tva.
*/
