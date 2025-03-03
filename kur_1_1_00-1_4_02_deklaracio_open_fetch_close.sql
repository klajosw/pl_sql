DECLARE
  /* Megadja az ügyfeleket ábécé sorrendben. 
     Van RETURN utasításrész. */
  CURSOR cur_ugyfelek RETURN ugyfel%ROWTYPE IS
    SELECT * FROM ugyfel
      ORDER BY UPPER(nev);

  v_Uid    ugyfel.id%TYPE;

  /* Megadja annak az ügyfélnek nevét és telefonszámát, melynek
     azonosítóját egy blokkbeli változó tartalmazza. 
     Nincs RETURN utasításrész, hisz a kérdésbõl ez úgyis kiderül. */
  CURSOR cur_ugyfel1 IS
    SELECT nev, tel_szam FROM ugyfel 
      WHERE id = v_Uid;

  /* Megadja a paraméterként átadott azonosítóval
     rendelkezõ ügyfelet. Ha nincs paraméter, akkor
     a megadott kezdõérték érvényes. */
  CURSOR cur_ugyfel2(p_Uid ugyfel.id%TYPE DEFAULT v_Uid) IS
    SELECT * FROM ugyfel 
      WHERE id = p_Uid;

  /* Megadja az adott dátum szerint lejárt
     kölcsönzésekhez az ügyfél nevét, a könyv címét,
     valamint a lejárat óta eltelt napok számának
     egész részét. 
     Ha nem adunk meg dátumot, akkor az aktuális
     dátum lesz a kezdeti érték. */
  CURSOR cur_lejart_kolcsonzesek(
    p_Datum   DATE DEFAULT SYSDATE
  ) IS
    SELECT napok, u.nev, k.cim
      FROM ugyfel u, konyv k,
      (SELECT TRUNC(p_Datum, 'DD') - TRUNC(datum) 
                - 30*(hosszabbitva+1) AS napok, 
              kolcsonzo, konyv
         FROM kolcsonzes) uk
      WHERE uk.kolcsonzo = u.id
        AND uk.konyv = k.id
        AND napok > 0
      ORDER BY UPPER(u.nev), UPPER(k.cim)
  ;

  /* Egy megfelelõ típusú változóba lehet majd a kurzor sorait betölteni */
  v_Lejart       cur_lejart_kolcsonzesek%ROWTYPE; 
  v_Nev          v_Lejart.nev%TYPE;

  /* Lekérdezi és zárolja az adott azonosítójú könyv sorát.
     Nem az egész táblát zárolja, csak az aktív halmaz elemeit!
     Erre akkor lehet például szükség, ha egy könyv kölcsönzésénél
     ellenõrízzük, hogy biztosan van-e még példány.
     Így biztosan nem lesz gond. ha két kölcsönzés egyszerre történik
     ugyanarra könyvre. Az egyik biztosan bevárja a másikat. */
  CURSOR cur_konyvzarolo(p_Kid konyv.id%TYPE) IS
    SELECT * FROM konyv
      WHERE id = p_Kid
      FOR UPDATE OF cim;

  /* Kísérletet tesz az adott könyv zárolására.
     Ha az erõforrást foglaltsága miatt nem
     lehet megnyitni, ORA-00054 kivétel váltódik ki. */
  CURSOR cur_konyvzarolo2(p_Kid konyv.id%TYPE) IS
    SELECT * FROM konyv
      WHERE id = p_Kid
      FOR UPDATE NOWAIT;

  /* Ezek a változók kompatibilisek az elõzõ kurzorokkal.
     Döntse el, melyik kurzor melyik változóval kompatibilis! */
  v_Ugyfel      ugyfel%ROWTYPE;  
  v_Konyv       konyv%ROWTYPE;  
  v_Unev        ugyfel.nev%TYPE;
  v_Utel_szam   ugyfel.tel_szam%TYPE;

BEGIN
  v_Uid := 15;  -- József István ügyfél azonosítója

  /* Mely sorok lesznek az aktív halmaz elemei ? */
  OPEN cur_ugyfel1; 
  OPEN cur_ugyfel2(15);

  LOOP
    FETCH cur_ugyfel1 INTO v_Unev, v_Utel_szam;
    EXIT WHEN cur_ugyfel1%NOTFOUND;

    /* Itt jön a feldolgozás, kiíratjuk a neveket. */
    DBMS_OUTPUT.PUT_LINE(v_Unev || ', ' || v_Utel_szam);
  END LOOP;

  CLOSE cur_ugyfel1;
  CLOSE cur_ugyfel2;
  DBMS_OUTPUT.NEW_LINE;

  /* Mivel a paraméter mindig IN típusú, 
     kifejezés is lehet aktuális paraméter. */
  OPEN cur_lejart_kolcsonzesek(TO_DATE('02-MÁJ.  -09'));
  BEGIN
    OPEN cur_lejart_kolcsonzesek; -- CURSOR_ALREADY_OPEN kivételt vált ki!
  EXCEPTION
    WHEN CURSOR_ALREADY_OPEN THEN
      DBMS_OUTPUT.PUT_LINE('Hiba: ' || SQLERRM);
  END;

  v_Nev := NULL;
  LOOP
    FETCH cur_lejart_kolcsonzesek INTO v_Lejart;
    EXIT WHEN cur_lejart_kolcsonzesek%NOTFOUND;

    /* Jöhet a feldolgozás, mondjuk figyelmeztetõ e-mail küldése.
       Most csak kiírjuk az egyes nevekhez a lejárt könyveket. */
    IF v_Nev IS NULL OR v_Nev <> v_Lejart.nev THEN
      v_Nev := v_Lejart.nev;
      DBMS_OUTPUT.NEW_LINE;
      DBMS_OUTPUT.PUT_LINE('Ügyfél: ' || v_Nev);
    END IF;
    DBMS_OUTPUT.PUT_LINE('   ' || v_Lejart.napok || ' nap, ' 
      || v_Lejart.cim);
  END LOOP;

  CLOSE cur_lejart_kolcsonzesek;
END;
/

/*
Eredmény:

József István, 06-52-456654

Hiba: ORA-06511: PL/SQL: a kurzor már meg van nyitva

Ügyfél: Jaripekka Hämälainen
   22 nap, A critical introduction to twentieth-century American drama - Volume 2
   22 nap, The Norton Anthology of American Literature - Second Edition - Volume 2

Ügyfél: József István
   17 nap, ECOOP 2001 - Object-Oriented Programming
   17 nap, Piszkos Fred és a többiek

A PL/SQL eljárás sikeresen befejezõdött.
*/
