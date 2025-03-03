/*
  A következõ trigger segítségével a kölcsönzés
  adminisztrácója automatizálható.

  Ugyanis egyetlen sor beszúrása kolcsonzes táblába
  maga után vonja az ugyfel és a konyv táblák megfelelõ
  bejegyzéseinek változtatását.

  A trigger sor szintû. Ha nem lehet a kölcsönzést
  végrehajtani, kivételt dobunk.
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
      v_Ugyfel.nev || ' ügyfél nem kölcsönözhet több könyvet.');
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
        'Nincs a könyvbõl több példány.');
  END;
END tr_insert_kolcsonzes;
/
show errors

/*
  Nézzünk néhány példát.
  A példák az inicializált adatbázis adatain futnak.
*/

/*
  József István és az 'SQL:1999 ...' könyv
  Sajnos az ügyfél nem kölcsönözhet többet.
*/
INSERT INTO kolcsonzes (kolcsonzo, konyv, datum)
  VALUES (15, 30, SYSDATE);
/*
INSERT INTO kolcsonzes (kolcsonzo, konyv, datum)
            *
Hiba a(z) 1. sorban:
ORA-20010: József István ügyfél nem kölcsönözhet több könyvet.
ORA-06512: a(z) "PLSQL.TR_INSERT_KOLCSONZES", helyen a(z) 8. sornál
ORA-04088: hiba a(z) 'PLSQL.TR_INSERT_KOLCSONZES' trigger futása közben
*/

/*
  Komor Ágnes és az 'A critical introduction... ' könyv
  Sajnos az könyvbõl nincs szabad példány.
*/
INSERT INTO kolcsonzes (kolcsonzo, konyv, datum)
  VALUES (30, 35, SYSDATE);
/*
INSERT INTO kolcsonzes (kolcsonzo, konyv, datum)
            *
Hiba a(z) 1. sorban:
ORA-20020: Nincs a könyvbõl több példány.
ORA-06512: a(z) "PLSQL.TR_INSERT_KOLCSONZES", helyen a(z) 21. sornál
ORA-04088: hiba a(z) 'PLSQL.TR_INSERT_KOLCSONZES' trigger futása közben
*/

/*
  Komor Ágnes és a 'The Norton Anthology... ' könyv
  Minden rendben lesz.
*/
INSERT INTO kolcsonzes (kolcsonzo, konyv, datum)
  VALUES (30, 40, SYSDATE);
SELECT * FROM TABLE(SELECT konyvek FROM ugyfel
                      WHERE id = 30);
/*

1 sor létrejött.

  KONYV_ID DATUM
---------- ---------
         5 02-ÁPR.  -12
        10 02-MÁRC. -12
        40 06-JÚN.  -23
*/
