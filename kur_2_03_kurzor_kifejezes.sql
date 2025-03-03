DECLARE
  TYPE t_Konyv_rec IS RECORD (
    id      konyv.id%TYPE,
    cim     konyv.cim%TYPE
  );
  
  TYPE t_konyvref IS REF CURSOR RETURN t_Konyv_rec;

  /* Lekérdezzük az ügyfeleket és a kölcsönzött könyveiket,
     azt az ügyfélt is, akinél nincs könyv. 
     A könyveket egy CURSOR-kifejezés segítségével adjuk vissza. */
  CURSOR cur_ugyfel_konyv IS
  SELECT id, nev, 
         CURSOR(SELECT k.id, k.cim FROM konyv k, TABLE(konyvek) uk
           WHERE k.id = uk.konyv_id) AS konyvlista
    FROM ugyfel
    ORDER BY UPPER(nev);

  v_Uid       ugyfel.id%TYPE;
  v_Unev      ugyfel.nev%TYPE;
  v_Konyvek   t_konyvref;
  v_Konyv     t_Konyv_rec;

BEGIN
  OPEN cur_ugyfel_konyv;
  LOOP
    FETCH cur_ugyfel_konyv INTO v_Uid, v_Unev, v_Konyvek;
    EXIT WHEN cur_ugyfel_konyv%NOTFOUND;
    
    DBMS_OUTPUT.NEW_LINE;
    DBMS_OUTPUT.PUT_LINE('Ügyfél: ' || v_Uid || ', ' || v_Unev);
                                  
    /* Most a beágyazott kurzor elemeit írjuk ki, ha nem üres.
       A beágyazott kurzort nem kell külön megnyitni és lezárni sem. */
    FETCH v_Konyvek INTO v_Konyv;
    IF v_Konyvek%FOUND THEN
      DBMS_OUTPUT.PUT_LINE('  A kölcsönzött könyvek:');
      WHILE v_Konyvek%FOUND LOOP
        DBMS_OUTPUT.PUT_LINE('    ' || v_Konyv.id || ', ' || v_Konyv.cim);
        FETCH v_Konyvek INTO v_Konyv;
      END LOOP;
    ELSE
      DBMS_OUTPUT.PUT_LINE('  jelenleg nem kölcsönöz könyvet.');

    END IF;
  END LOOP;

  CLOSE cur_ugyfel_konyv;
END;
/

/*
Eredmény:

Ügyfél: 25, Erdei Anita
  A kölcsönzött könyvek:
    35, A critical introduction to twentieth-century American drama - Volume 2

Ügyfél: 35, Jaripekka Hämälainen
  A kölcsönzött könyvek:
    35, A critical introduction to twentieth-century American drama - Volume 2
    40, The Norton Anthology of American Literature - Second Edition - Volume 2

Ügyfél: 15, József István
  A kölcsönzött könyvek:
    15, Piszkos Fred és a többiek
    20, ECOOP 2001 - Object-Oriented Programming
    25, Java - start!
    45, Matematikai zseblexikon
    50, Matematikai Kézikönyv

Ügyfél: 30, Komor Ágnes
  A kölcsönzött könyvek:
    5, A római jog története és institúciói
    10, A teljesség felé

Ügyfél: 5, Kovács János
  jelenleg nem kölcsönöz könyvet.

Ügyfél: 10, Szabó Máté István
  A kölcsönzött könyvek:
    30, SQL:1999 Understanding Relational Language Components
    45, Matematikai zseblexikon
    50, Matematikai Kézikönyv

Ügyfél: 20, Tóth László
  A kölcsönzött könyvek:
    30, SQL:1999 Understanding Relational Language Components

A PL/SQL eljárás sikeresen befejezõdött.
*/
