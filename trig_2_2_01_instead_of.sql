/*
  Az INSTEAD OF triggerek lehetõvé teszik nézetek módosítását.  

  Megpróbáljuk módosítani egy ügyfél nevét az ugyfel_konyv
  nézet sorain keresztül.
*/
UPDATE ugyfel_konyv SET ugyfel = 'József István TRIGGERES' 
  WHERE ugyfel_id = 15;
/*
UPDATE ugyfel_konyv SET ugyfel = 'József István TRIGGERES' 
                        *
Hiba a(z) 1. sorban:
ORA-01779: nem módosítható olyan oszlop, amely egy kulcsot nem megõrzõ táblára utal
*/

/*
  A következõ trigger segítségével egy ügyfél nevét, vagy
  egy könyv címét módosíthatjuk az ugyfel_konyv nézeten
  keresztül. Ha azonosítót is megpróbálnak változtatni
  azzal egyszerûen nem törõdünk (nem váltunk ki kivételt).
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
  Megpróbálunk módosítani megint.
*/
UPDATE ugyfel_konyv SET ugyfel = 'József István TRIGGERES' 
  WHERE ugyfel_id = 15;
/*
5 sor módosítva.
*/
