/*
  A k�vetkez� trigger seg�ts�g�vel a k�lcs�nz�s
  adminisztr�c�ja automatiz�lhat�.

  Ugyanis egyetlen sor besz�r�sa kolcsonzes t�bl�ba
  maga ut�n vonja az ugyfel �s a konyv t�bl�k megfelel�
  bejegyz�seinek v�ltoztat�s�t.

  A trigger sor szint�. Ha nem lehet a k�lcs�nz�st
  v�grehajtani, kiv�telt dobunk.
*/
CREATE OR REPLACE TRIGGER tr_insert_kolcsonzes
  AFTER INSERT ON kolcsonzes
  FOR EACH ROW
DECLARE
  v_Ugyfel   ugyfel%ROWTYPE;
BEGIN
  SELECT * INTO v_Ugyfel
    FROM ugyfel WHERE id = :NEW.kolcsonzo;

  IF v_Ugyfel.max_konyv = v_Ugyfel.konyvek.COUNT THEN
    RAISE_APPLICATION_ERROR(-20010, 
      v_Ugyfel.nev || ' �gyf�l nem k�lcs�n�zhet t�bb k�nyvet.');
  END IF;

  INSERT INTO TABLE(SELECT konyvek FROM ugyfel 
                      WHERE id = :NEW.kolcsonzo)
    VALUES (:NEW.konyv, :NEW.datum);

  BEGIN
    UPDATE konyv SET szabad = szabad - 1
      WHERE id = :NEW.konyv;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20020, 
        'Nincs a k�nyvb�l t�bb p�ld�ny.');
  END;
END tr_insert_kolcsonzes;
/
show errors

/*
  N�zz�nk n�h�ny p�ld�t.
  A p�ld�k az inicializ�lt adatb�zis adatain futnak.
*/

/*
  J�zsef Istv�n �s az 'SQL:1999 ...' k�nyv
  Sajnos az �gyf�l nem k�lcs�n�zhet t�bbet.
*/
INSERT INTO kolcsonzes (kolcsonzo, konyv, datum)
  VALUES (15, 30, SYSDATE);
/*
INSERT INTO kolcsonzes (kolcsonzo, konyv, datum)
            *
Hiba a(z) 1. sorban:
ORA-20010: J�zsef Istv�n �gyf�l nem k�lcs�n�zhet t�bb k�nyvet.
ORA-06512: a(z) "PLSQL.TR_INSERT_KOLCSONZES", helyen a(z) 8. sorn�l
ORA-04088: hiba a(z) 'PLSQL.TR_INSERT_KOLCSONZES' trigger fut�sa k�zben
*/

/*
  Komor �gnes �s az 'A critical introduction... ' k�nyv
  Sajnos az k�nyvb�l nincs szabad p�ld�ny.
*/
INSERT INTO kolcsonzes (kolcsonzo, konyv, datum)
  VALUES (30, 35, SYSDATE);
/*
INSERT INTO kolcsonzes (kolcsonzo, konyv, datum)
            *
Hiba a(z) 1. sorban:
ORA-20020: Nincs a k�nyvb�l t�bb p�ld�ny.
ORA-06512: a(z) "PLSQL.TR_INSERT_KOLCSONZES", helyen a(z) 21. sorn�l
ORA-04088: hiba a(z) 'PLSQL.TR_INSERT_KOLCSONZES' trigger fut�sa k�zben
*/

/*
  Komor �gnes �s a 'The Norton Anthology... ' k�nyv
  Minden rendben lesz.
*/
INSERT INTO kolcsonzes (kolcsonzo, konyv, datum)
  VALUES (30, 40, SYSDATE);
SELECT * FROM TABLE(SELECT konyvek FROM ugyfel
                      WHERE id = 30);
/*

1 sor l�trej�tt.

  KONYV_ID DATUM
---------- ---------
         5 02-�PR.  -12
        10 02-M�RC. -12
        40 06-J�N.  -23
*/
