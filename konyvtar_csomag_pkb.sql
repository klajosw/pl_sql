CREATE OR REPLACE PACKAGE BODY konyvtar_csomag
AS
  /***********************/
  /* Privát deklarációk. */
  /***********************/

  /* A csomag statisztikáját tartalmazó privát rekord. */
  v_Stat            t_statisztika_rec;


  /*******************/
  /* Implementációk. */
  /*******************/

  /* Megadja a lejárt kölcsönzéseket. */
  CURSOR cur_lejart_kolcsonzesek(
    p_Datum DATE DEFAULT SYSDATE
  ) RETURN t_lejart_rec
  IS
    SELECT kolcsonzo, konyv, datum,
           hosszabbitva, megjegyzes, napok
      FROM 
        (SELECT kolcsonzo, konyv, datum, hosszabbitva, megjegyzes, 
                TRUNC(p_Datum, 'DD') - TRUNC(datum, 'DD')
                  - 30*(hosszabbitva+1) AS napok
           FROM kolcsonzes) 
        WHERE napok > 0
  ;

  /***********************/
  /* Privát alprogramok. */
  /***********************/

  /* Beállítja a v_Stat utolsó módosítási dátumát. */
  PROCEDURE stat_akt
  IS
  BEGIN
    v_Stat.utolso_modositas := SYSDATE;
  END stat_akt;

  /* Pontosan p_Hossz hosszan adja meg a p_Sztringet, ha kell 
     csonkolja, ha kell szóközökkel egészíti ki. */
  FUNCTION str(
    p_Sztring   VARCHAR2,
    p_Hossz     INTEGER
  ) RETURN VARCHAR2 IS
  BEGIN
    RETURN RPAD(SUBSTR(p_Sztring, 1, p_Hossz), p_Hossz);
  END str;

  /* Kivételek kiváltása hibaüzenetekkel. */
  PROCEDURE raise_hibas_argumentum
  IS
  BEGIN
    RAISE_APPLICATION_ERROR(-20100, 'Hibás argumentum');
  END raise_hibas_argumentum;

  PROCEDURE raise_ervenytelen_kolcsonzes
  IS
  BEGIN
    RAISE_APPLICATION_ERROR(-20110, 'Érvénytelen kölcsönzés');
  END raise_ervenytelen_kolcsonzes;

  PROCEDURE raise_kurzor_hasznalatban
  IS
  BEGIN
    RAISE_APPLICATION_ERROR(-20120, 'A kurzor használatban van.');
  END raise_kurzor_hasznalatban;


  /*************************************************/
  /* A könyvtárban használatos gyakori alprogramok */
  /*************************************************/

  /*
     Megadja az ügyfelet az azonosítóhoz. 
     Nemlétezõ ügyfél esetén hibas_argumentum kivételt vált ki.
  */
  FUNCTION az_ugyfel(p_Ugyfel ugyfel.id%TYPE) 
  RETURN ugyfel%ROWTYPE IS
    v_Ugyfel    ugyfel%ROWTYPE;
  BEGIN
    SELECT * INTO v_Ugyfel 
      FROM ugyfel WHERE id = p_Ugyfel;
    RETURN v_Ugyfel;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      raise_hibas_argumentum;
  END az_ugyfel;

  /*
     Megadja a könyvet az azonosítóhoz. 
     Nemlétezõ könyv esetén hibas_argumentum kivételt vált ki.
  */
  FUNCTION a_konyv(p_Konyv konyv.id%TYPE)
  RETURN konyv%ROWTYPE IS
    v_Konyv     konyv%ROWTYPE;
  BEGIN
    SELECT * INTO v_Konyv 
      FROM konyv WHERE id = p_Konyv;
    RETURN v_Konyv;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      raise_hibas_argumentum;
  END a_konyv;

  /* 
    Felvesz egy ügyfelet a könyvtárba a szokásos
    kezdeti kvótával és az aktuális dátummal, a
    kölcsönzött könyvek oszlopot üres kollekcióra állítja.
    
    Visszatérési értéke az új ügyfél azonosítója.
  */
  FUNCTION uj_ugyfel(
    p_Nev           ugyfel.nev%TYPE,
    p_Anyja_neve    ugyfel.anyja_neve%TYPE,
    p_Lakcim        ugyfel.lakcim%TYPE,
    p_Tel_szam      ugyfel.tel_szam%TYPE,
    p_Foglalkozas   ugyfel.foglalkozas%TYPE
  ) RETURN ugyfel.id%type IS
    v_Id   ugyfel.id%type;
  BEGIN
    SELECT ugyfel_seq.nextval
      INTO v_Id
      FROM dual;

    INSERT INTO ugyfel VALUES
      (v_Id, p_Nev, p_Anyja_neve,
       p_Lakcim, p_Tel_szam, p_Foglalkozas,
       SYSDATE, c_Max_konyv_init, T_Konyvek());

    /* A statisztika aktualizálása. */
    stat_akt;
    v_Stat.uj_ugyfelek := v_Stat.uj_ugyfelek + 1;

    RETURN v_Id;
  END uj_ugyfel;

  /* 
    Raktárra vesz az adott ISBN kódú könyvbõl megadott példányt.

    Ha van már ilyen könyv, akkor hozzáadja az új készletet
    a régihez. Ilyenkor csak az ISBN számot egyezteti,
    a többi paraméter értékét a függvény nem veszi figyelembe.
    
    Visszatérési érték a könyvek azonosítója.
  */
  FUNCTION konyv_raktarba(
    p_ISBN          konyv.ISBN%TYPE,
    p_Cim           konyv.cim%TYPE,
    p_Kiado         konyv.kiado%TYPE,
    p_Kiadasi_ev    konyv.kiadasi_ev%TYPE,
    p_Szerzo        konyv.szerzo%TYPE,
    p_Darab         INTEGER
  ) RETURN konyv.id%type IS
    v_Id   konyv.id%type;
  BEGIN
    /* Megpróbáljuk módosítani a könyv adatait. */
    UPDATE konyv
      SET keszlet = keszlet + p_Darab,
          szabad  = szabad + p_Darab
      WHERE
        UPPER(ISBN) = UPPER(p_ISBN)
      RETURNING id INTO v_Id;
    
    IF SQL%NOTFOUND THEN
      /* Mégiscsak INSERT lesz ez. */
      SELECT konyv_seq.nextval
        INTO v_Id
        FROM dual;

      INSERT INTO konyv VALUES
        (v_Id, p_ISBN, p_Cim,
         p_Kiado, p_Kiadasi_ev, p_Szerzo,
         p_Darab, p_Darab);

      /* A statisztika aktualizálása. */
      stat_akt;
      v_Stat.uj_konyvek := v_Stat.uj_konyvek + 1;
    END IF;

    RETURN v_Id;
  END konyv_raktarba;

  /*
    Egy ügyfél számára kölcsönöz egy könyvet:
     - felveszi a kölcsönzési rekordot a kolcsonzes táblába
       és az ugyfel.konyvek beágyazott táblába;
     - aktualizálja az ügyfél kvótáját és a könyv szabad 
       példányainak számát.

    Nemlétezõ könyv, illetve ügyfél esetén hibas_argumentum kivétel,
    ha az ügyfélnek 0 a kvótája, vagy nincs szabad példány, akkor
    ervenytelen_kolcsonzes kivétel váltódik ki.
  */
  PROCEDURE kolcsonoz(
    p_Ugyfel        ugyfel.id%TYPE,
    p_Konyv         konyv.id%TYPE
  ) IS
    V_Most      DATE;
    v_Szam      NUMBER;
  BEGIN
    SAVEPOINT kezdet;
    v_Most := SYSDATE;

    /* Próbáljuk meg beszúrni a kölcsönzési rekordot. */
    BEGIN
      INSERT INTO kolcsonzes VALUES (p_Ugyfel, p_Konyv, v_Most, 0,
           'A bejegyzést a konyvtar_csomag hozta létre');
    EXCEPTION
      WHEN OTHERS THEN
        -- Csak az integritási megszorítással lehetett baj.
        raise_hibas_argumentum;
    END;

    BEGIN
      /* A következõ SELECT nem ad vissza sort,
         ha nem lehet többet kölcsönöznie az ügyfélnek. */
      SELECT 1 INTO v_Szam 
        FROM ugyfel
        WHERE id = p_Ugyfel
          AND max_konyv - (SELECT COUNT(1) FROM TABLE(konyvek)) > 0;

      /* Ha csökkentjük a szabad példányok számát
         megsérthetjük a konyv_szabad megszorítást. */
      UPDATE konyv SET szabad = szabad - 1 WHERE id = p_Konyv;

      INSERT INTO TABLE(SELECT konyvek FROM ugyfel WHERE id = p_Ugyfel)
        VALUES (p_Konyv, v_Most);
    
      /* A statisztika aktualizálása. */
      stat_akt;
      v_Stat.kolcsonzesek := v_Stat.kolcsonzesek + 1;

    EXCEPTION
      WHEN OTHERS THEN -- kvóta vagy szabad példány nem megfelelõ
        ROLLBACK TO kezdet; 
        raise_ervenytelen_kolcsonzes;
    END;
  END kolcsonoz;

  /*
    Adminisztrálja egy könyv visszahozatalát:
     - naplózza a kölcsönzést a kolcsonzes_naplo táblában;
     - törli a kölcsönzési rekordot a kolcsonzes táblából
       és az ugyfel.konyvek beágyazott táblából;
     - aktualizálja a könyv szabad példányainak számát.

    Ha a paraméterek nem jelölnek valódi kölcsönzési
    bejegyzést, akkor hibas_argumentum kivétel váltódik ki.
  */
  PROCEDURE visszahoz(
    p_Ugyfel        ugyfel.id%TYPE,
    p_Konyv         konyv.id%TYPE
  ) IS
    v_Datum     kolcsonzes.datum%TYPE;
  BEGIN
    DELETE FROM kolcsonzes 
      WHERE konyv = p_Konyv
        AND kolcsonzo = p_Ugyfel
        AND rownum = 1
    RETURNING datum INTO v_Datum;

    IF SQL%ROWCOUNT = 0 THEN
      raise_hibas_argumentum;
    END IF;

    UPDATE konyv SET szabad = szabad + 1
      WHERE id = p_Konyv;

    DELETE FROM TABLE(SELECT konyvek FROM ugyfel WHERE id = p_Ugyfel)
      WHERE konyv_id = p_konyv
        AND datum = v_Datum;

    /* A statisztika aktualizálása */
    stat_akt;
    v_Stat.visszahozott_konyvek := v_Stat.visszahozott_konyvek - 1;
  END visszahoz;

  /*
    Adminisztrálja egy ügyfél összes könyvének visszahozatalát:
     - naplózza a kölcsönzéseket a kolcsonzes_naplo táblában;
     - törli a kölcsönzési rekordokat a kolcsonzes táblából
       és az ugyfel.konyvek beágyazott táblából;
     - aktualizálja a könyvek szabad példányainak számát.

    Ha az ügyfél nem létezik hibas_argumentum kivétel váltódik ki.

    Megj.: Ez az eljárásnév túl van terhelve.
  */
  PROCEDURE visszahoz(
    p_Ugyfel        ugyfel.id%TYPE
  ) IS
    v_Szam  NUMBER;
  BEGIN
    /* A csoportfüggvényeket tartalmazó SELECT 
       mindig ad vissza sort. */ 
    SELECT COUNT(1) INTO v_Szam
      FROM ugyfel WHERE id = p_Ugyfel;

    IF v_Szam = 0 THEN
      raise_hibas_argumentum;
    END IF;
    
    /* Töröljük egyenként a kölcsönzéseket. */
    FOR k IN (
      SELECT * FROM kolcsonzes 
        WHERE kolcsonzo = p_Ugyfel
    ) LOOP
      visszahoz(p_Ugyfel, k.konyv);
    END LOOP;
  END visszahoz;

  /*
    Kilistázza a lejárt kölcsönzési rekordokat.

    Ha a cur_lejart_kolcsonzesek kurzor nyitva van,
    az eljárás nem használható. Ilyenkor 
    kurzor_hasznalatban kivétel váltódik ki.
  */
  PROCEDURE lejart_konyvek
  IS
  BEGIN
    IF cur_lejart_kolcsonzesek%ISOPEN THEN
      raise_kurzor_hasznalatban;
    END IF;

    DBMS_OUTPUT.PUT_LINE(str('Ügyfél', 40) || ' ' || str('Könyv', 50) 
      || ' ' || str('dátum', 18) || 'napok');
    DBMS_OUTPUT.PUT_LINE(RPAD('', 120, '-'));
    FOR k IN cur_lejart_kolcsonzesek LOOP
      DBMS_OUTPUT.PUT_LINE(
        str(k.kolcsonzo || ' ' || az_ugyfel(k.kolcsonzo).nev, 40)
        || ' ' || str(k.konyv || ' ' || a_konyv(k.konyv).cim, 50)
        || ' ' || TO_CHAR(k.datum, 'YYYY-MON-DD HH24:MI') 
        || ' ' || k.napok
      );
    END LOOP;
  END lejart_konyvek;

  /*
    Kilistázza a lejárt kölcsönzési rekordok közül
    azokat, amelyek ma jártak le.

    Ha a cur_lejart_kolcsonzesek kurzor nyitva van,
    az eljárás nem használható. Ilyenkor 
    kurzor_hasznalatban kivétel váltódik ki.
  */
  PROCEDURE mai_lejart_konyvek
  IS
  BEGIN
    IF cur_lejart_kolcsonzesek%ISOPEN THEN
      raise_kurzor_hasznalatban;
    END IF;

    DBMS_OUTPUT.PUT_LINE(str('Ügyfél', 40) || ' ' || str('Könyv', 50) 
      || ' ' || str('dátum', 18) || 'napok');
    DBMS_OUTPUT.PUT_LINE(RPAD('', 120, '-'));
    FOR k IN cur_lejart_kolcsonzesek LOOP
      IF k.napok = 1 THEN
        DBMS_OUTPUT.PUT_LINE(
          str(k.kolcsonzo || ' ' || az_ugyfel(k.kolcsonzo).nev, 40)
          || ' ' || str(k.konyv || ' ' || a_konyv(k.konyv).cim, 50)
          || ' ' || TO_CHAR(k.datum, 'YYYY-MON-DD HH24:MI') 
        );
      END IF;
    END LOOP;
  END mai_lejart_konyvek;

  /*
     Megadja egy kölcsönzött könyv hátralevõ kölcsönzési idejét.

     hibas_argumentum kivételt vált ki, ha nincs ilyen kölcsönzés.
   */
  FUNCTION hatralevo_napok(
    p_Ugyfel    ugyfel.id%TYPE, 
    p_Konyv     konyv.id%TYPE
  ) RETURN INTEGER
  IS
    v_Datum          kolcsonzes.datum%TYPE;
    v_Most           DATE;
    v_Hosszabbitva   kolcsonzes.hosszabbitva%TYPE;  
  BEGIN
    SELECT datum, hosszabbitva
      INTO v_Datum, v_Hosszabbitva
      FROM kolcsonzes
      WHERE kolcsonzo = p_Ugyfel
        AND konyv     = p_Konyv;

    /* Levágjuk a dátumokból az óra részt. */
    v_Datum := TRUNC(v_Datum, 'DD');
    v_Most  := TRUNC(SYSDATE, 'DD');

    /* Visszaadjuk a különbséget. */
    RETURN (v_Hosszabbitva + 1) * 30 + v_Datum - v_Most;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      raise_hibas_argumentum;
  END hatralevo_napok;


  /*******************************************************************/
  /* A csomag használatára vonatkozó statisztikát kezelõ alprogramok */
  /*******************************************************************/

  /*
    Megadja a statisztikát a legutóbbi nullázás, ill.
    az indulás óta.
  */
  FUNCTION statisztika RETURN t_statisztika_rec
  IS
  BEGIN 
    RETURN v_Stat;
  END statisztika;

  /*
    Kiírja a statisztikát a legutóbbi nullázás ill.
    az indulás óta.
  */
  PROCEDURE print_statisztika
  IS
  BEGIN 
    DBMS_OUTPUT.PUT_LINE('Statisztika a munkamenetben:');
    DBMS_OUTPUT.NEW_LINE;
    DBMS_OUTPUT.PUT_LINE(RPAD('Regisztrált új ügyfelek száma:', 40)
      || v_Stat.uj_ugyfelek);
    DBMS_OUTPUT.PUT_LINE(RPAD('Regisztrált új könyvek száma:', 40)
      || v_Stat.uj_konyvek);
    DBMS_OUTPUT.PUT_LINE(RPAD('Kölcsönzések száma:', 40)
      || v_Stat.kolcsonzesek);
    DBMS_OUTPUT.PUT_LINE(RPAD('Visszahozott könyvek száma:', 40)
      || v_Stat.visszahozott_konyvek);

    DBMS_OUTPUT.PUT_LINE(RPAD('Utolsó módosítás: ', 40) 
      || TO_CHAR(v_Stat.utolso_modositas, 'YYYY-MON-DD HH24:MI:SS'));
    DBMS_OUTPUT.PUT_LINE(RPAD('Statisztika kezdete: ', 40)
      || TO_CHAR(v_Stat.utolso_nullazas, 'YYYY-MON-DD HH24:MI:SS'));
  END print_statisztika;
  
  /*
    Nullázza a statiszikát.
  */
  PROCEDURE statisztika_nullaz
  IS
    v_Stat2     t_statisztika_rec;
  BEGIN 
    v_Stat := v_Stat2;
  END statisztika_nullaz;


/********************************/
/* A csomag inicializáló része. */
/********************************/
BEGIN
  statisztika_nullaz;  
END konyvtar_csomag;
/
show errors
