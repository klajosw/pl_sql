/*
   A következõkben megadunk egy eljárást, amely
   adminisztrálja egy könyv kölcsönzését. A kölcsonzés sikeres,
   ha van szabad pédány a könyvbõl és a felhsználó még kölcsönözhet 
   könyvet. Egyébként a kölcsönzés nem sikeres és a hiba okát
   kiírjuk.
  
   Az eljárás használatát a tartalmazó blokk demonstrálja.
*/

DECLARE

  PROCEDURE kolcsonoz(
    p_Ugyfel_id    ugyfel.id%TYPE, 
    p_Konyv_id     konyv.id%TYPE, 
    p_Megjegyzes   kolcsonzes.megjegyzes%TYPE
  ) IS
    -- A könyvbõl ennyi szabad példány van.
    v_Szabad            konyv.szabad%TYPE;
  
    -- Az ügyfélnél levõ könyvek száma
    v_Kolcsonzott       PLS_INTEGER;
    -- Az ügyfél által maximum kölcsönözhetõ könyvek száma
    v_Max_konyv         ugyfel.max_konyv%TYPE;
  
    v_Datum             kolcsonzes.datum%TYPE;
  
  BEGIN
    DBMS_OUTPUT.NEW_LINE;
    DBMS_OUTPUT.PUT_LINE('Kölcsönzés - ügyfél id: ' || p_Ugyfel_id
      || ', könyv id: ' || p_Konyv_id || '.');
    -- Van-e szabad példány a könyvbõl?
    SELECT szabad 
      INTO v_Szabad 
      FROM konyv
      WHERE id = p_Konyv_id;

    IF v_Szabad = 0 THEN
      DBMS_OUTPUT.PUT_LINE('Hiba! A könyv minden példánya ki van kölcsönözve.');
      RETURN;
    END IF;
   
    -- Kölcsönözhet még az ügyfél könyvet?
    SELECT COUNT(1) 
      INTO v_Kolcsonzott
      FROM TABLE(SELECT konyvek 
             FROM ugyfel
             WHERE id = p_Ugyfel_id);

    SELECT max_konyv
      INTO v_Max_konyv
      FROM ugyfel
      WHERE id = p_Ugyfel_id;

    IF v_Max_konyv <= v_Kolcsonzott THEN
      DBMS_OUTPUT.PUT_LINE('Hiba! Az ügyfél nem kölcsönözhet több könyvet.');
      RETURN;
    END IF;
    
    -- A kölcsönzésnek nincs akadálya
    v_Datum := SYSDATE;

    UPDATE konyv 
      SET szabad = szabad - 1
      WHERE id = p_Konyv_id;

    INSERT INTO kolcsonzes 
      VALUES (p_Ugyfel_id, p_Konyv_id, v_Datum, 0, p_Megjegyzes);

    INSERT INTO TABLE(SELECT konyvek 
             FROM ugyfel
           WHERE id = p_Ugyfel_id)
      VALUES (p_Konyv_id, v_Datum);
    DBMS_OUTPUT.PUT_LINE('Sikeres kölcsönzés.');
  END kolcsonoz;

BEGIN
  /* 
    Tóth László (20) kölcsönzi a 'Java - start!' címû könyvet (25).
  */
  kolcsonoz(20, 25, NULL);

  /* 
    József István (15) kölcsönzi a 'A teljesség felé' címû könyvet (10).
    Nem sikerül, mert az ügyfél már a maximális számú könyvet kölcsönzi.
  */
  kolcsonoz(15, 10, NULL);

  /* 
    Komor Ágnes (30) kölcsönzi a 'A critical introduction...' címû könyvet (35).
    Nem sikerül, mert a könyvbõl már nincs szabad példány.
  */
  kolcsonoz(30, 35, NULL);
END;
/

/*
Eredmény:

Kölcsönzés - ügyfél id: 20, könyv id: 25.
Sikeres kölcsönzés.

Kölcsönzés - ügyfél id: 15, könyv id: 10.
Hiba! Az ügyfél nem kölcsönözhet több könyvet.

Kölcsönzés - ügyfél id: 30, könyv id: 35.
Hiba! A könyv minden példánya ki van kölcsönözve.

A PL/SQL eljárás sikeresen befejezõdött.
*/
