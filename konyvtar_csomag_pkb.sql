CREATE OR REPLACE PACKAGE BODY konyvtar_csomag
AS
  /***********************/
  /* Priv�t deklar�ci�k. */
  /***********************/

  /* A csomag statisztik�j�t tartalmaz� priv�t rekord. */
  v_Stat            t_statisztika_rec;


  /*******************/
  /* Implement�ci�k. */
  /*******************/

  /* Megadja a lej�rt k�lcs�nz�seket. */
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
  /* Priv�t alprogramok. */
  /***********************/

  /* Be�ll�tja a v_Stat utols� m�dos�t�si d�tum�t. */
  PROCEDURE stat_akt
  IS
  BEGIN
    v_Stat.utolso_modositas := SYSDATE;
  END stat_akt;

  /* Pontosan p_Hossz hosszan adja meg a p_Sztringet, ha kell 
     csonkolja, ha kell sz�k�z�kkel eg�sz�ti ki. */
  FUNCTION str(
    p_Sztring   VARCHAR2,
    p_Hossz     INTEGER
  ) RETURN VARCHAR2 IS
  BEGIN
    RETURN RPAD(SUBSTR(p_Sztring, 1, p_Hossz), p_Hossz);
  END str;

  /* Kiv�telek kiv�lt�sa hiba�zenetekkel. */
  PROCEDURE raise_hibas_argumentum
  IS
  BEGIN
    RAISE_APPLICATION_ERROR(-20100, 'Hib�s argumentum');
  END raise_hibas_argumentum;

  PROCEDURE raise_ervenytelen_kolcsonzes
  IS
  BEGIN
    RAISE_APPLICATION_ERROR(-20110, '�rv�nytelen k�lcs�nz�s');
  END raise_ervenytelen_kolcsonzes;

  PROCEDURE raise_kurzor_hasznalatban
  IS
  BEGIN
    RAISE_APPLICATION_ERROR(-20120, 'A kurzor haszn�latban van.');
  END raise_kurzor_hasznalatban;


  /*************************************************/
  /* A k�nyvt�rban haszn�latos gyakori alprogramok */
  /*************************************************/

  /*
     Megadja az �gyfelet az azonos�t�hoz. 
     Neml�tez� �gyf�l eset�n hibas_argumentum kiv�telt v�lt ki.
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
     Megadja a k�nyvet az azonos�t�hoz. 
     Neml�tez� k�nyv eset�n hibas_argumentum kiv�telt v�lt ki.
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
    Felvesz egy �gyfelet a k�nyvt�rba a szok�sos
    kezdeti kv�t�val �s az aktu�lis d�tummal, a
    k�lcs�nz�tt k�nyvek oszlopot �res kollekci�ra �ll�tja.
    
    Visszat�r�si �rt�ke az �j �gyf�l azonos�t�ja.
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

    /* A statisztika aktualiz�l�sa. */
    stat_akt;
    v_Stat.uj_ugyfelek := v_Stat.uj_ugyfelek + 1;

    RETURN v_Id;
  END uj_ugyfel;

  /* 
    Rakt�rra vesz az adott ISBN k�d� k�nyvb�l megadott p�ld�nyt.

    Ha van m�r ilyen k�nyv, akkor hozz�adja az �j k�szletet
    a r�gihez. Ilyenkor csak az ISBN sz�mot egyezteti,
    a t�bbi param�ter �rt�k�t a f�ggv�ny nem veszi figyelembe.
    
    Visszat�r�si �rt�k a k�nyvek azonos�t�ja.
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
    /* Megpr�b�ljuk m�dos�tani a k�nyv adatait. */
    UPDATE konyv
      SET keszlet = keszlet + p_Darab,
          szabad  = szabad + p_Darab
      WHERE
        UPPER(ISBN) = UPPER(p_ISBN)
      RETURNING id INTO v_Id;
    
    IF SQL%NOTFOUND THEN
      /* M�giscsak INSERT lesz ez. */
      SELECT konyv_seq.nextval
        INTO v_Id
        FROM dual;

      INSERT INTO konyv VALUES
        (v_Id, p_ISBN, p_Cim,
         p_Kiado, p_Kiadasi_ev, p_Szerzo,
         p_Darab, p_Darab);

      /* A statisztika aktualiz�l�sa. */
      stat_akt;
      v_Stat.uj_konyvek := v_Stat.uj_konyvek + 1;
    END IF;

    RETURN v_Id;
  END konyv_raktarba;

  /*
    Egy �gyf�l sz�m�ra k�lcs�n�z egy k�nyvet:
     - felveszi a k�lcs�nz�si rekordot a kolcsonzes t�bl�ba
       �s az ugyfel.konyvek be�gyazott t�bl�ba;
     - aktualiz�lja az �gyf�l kv�t�j�t �s a k�nyv szabad 
       p�ld�nyainak sz�m�t.

    Neml�tez� k�nyv, illetve �gyf�l eset�n hibas_argumentum kiv�tel,
    ha az �gyf�lnek 0 a kv�t�ja, vagy nincs szabad p�ld�ny, akkor
    ervenytelen_kolcsonzes kiv�tel v�lt�dik ki.
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

    /* Pr�b�ljuk meg besz�rni a k�lcs�nz�si rekordot. */
    BEGIN
      INSERT INTO kolcsonzes VALUES (p_Ugyfel, p_Konyv, v_Most, 0,
           'A bejegyz�st a konyvtar_csomag hozta l�tre');
    EXCEPTION
      WHEN OTHERS THEN
        -- Csak az integrit�si megszor�t�ssal lehetett baj.
        raise_hibas_argumentum;
    END;

    BEGIN
      /* A k�vetkez� SELECT nem ad vissza sort,
         ha nem lehet t�bbet k�lcs�n�znie az �gyf�lnek. */
      SELECT 1 INTO v_Szam 
        FROM ugyfel
        WHERE id = p_Ugyfel
          AND max_konyv - (SELECT COUNT(1) FROM TABLE(konyvek)) > 0;

      /* Ha cs�kkentj�k a szabad p�ld�nyok sz�m�t
         megs�rthetj�k a konyv_szabad megszor�t�st. */
      UPDATE konyv SET szabad = szabad - 1 WHERE id = p_Konyv;

      INSERT INTO TABLE(SELECT konyvek FROM ugyfel WHERE id = p_Ugyfel)
        VALUES (p_Konyv, v_Most);
    
      /* A statisztika aktualiz�l�sa. */
      stat_akt;
      v_Stat.kolcsonzesek := v_Stat.kolcsonzesek + 1;

    EXCEPTION
      WHEN OTHERS THEN -- kv�ta vagy szabad p�ld�ny nem megfelel�
        ROLLBACK TO kezdet; 
        raise_ervenytelen_kolcsonzes;
    END;
  END kolcsonoz;

  /*
    Adminisztr�lja egy k�nyv visszahozatal�t:
     - napl�zza a k�lcs�nz�st a kolcsonzes_naplo t�bl�ban;
     - t�rli a k�lcs�nz�si rekordot a kolcsonzes t�bl�b�l
       �s az ugyfel.konyvek be�gyazott t�bl�b�l;
     - aktualiz�lja a k�nyv szabad p�ld�nyainak sz�m�t.

    Ha a param�terek nem jel�lnek val�di k�lcs�nz�si
    bejegyz�st, akkor hibas_argumentum kiv�tel v�lt�dik ki.
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

    /* A statisztika aktualiz�l�sa */
    stat_akt;
    v_Stat.visszahozott_konyvek := v_Stat.visszahozott_konyvek - 1;
  END visszahoz;

  /*
    Adminisztr�lja egy �gyf�l �sszes k�nyv�nek visszahozatal�t:
     - napl�zza a k�lcs�nz�seket a kolcsonzes_naplo t�bl�ban;
     - t�rli a k�lcs�nz�si rekordokat a kolcsonzes t�bl�b�l
       �s az ugyfel.konyvek be�gyazott t�bl�b�l;
     - aktualiz�lja a k�nyvek szabad p�ld�nyainak sz�m�t.

    Ha az �gyf�l nem l�tezik hibas_argumentum kiv�tel v�lt�dik ki.

    Megj.: Ez az elj�r�sn�v t�l van terhelve.
  */
  PROCEDURE visszahoz(
    p_Ugyfel        ugyfel.id%TYPE
  ) IS
    v_Szam  NUMBER;
  BEGIN
    /* A csoportf�ggv�nyeket tartalmaz� SELECT 
       mindig ad vissza sort. */ 
    SELECT COUNT(1) INTO v_Szam
      FROM ugyfel WHERE id = p_Ugyfel;

    IF v_Szam = 0 THEN
      raise_hibas_argumentum;
    END IF;
    
    /* T�r�lj�k egyenk�nt a k�lcs�nz�seket. */
    FOR k IN (
      SELECT * FROM kolcsonzes 
        WHERE kolcsonzo = p_Ugyfel
    ) LOOP
      visszahoz(p_Ugyfel, k.konyv);
    END LOOP;
  END visszahoz;

  /*
    Kilist�zza a lej�rt k�lcs�nz�si rekordokat.

    Ha a cur_lejart_kolcsonzesek kurzor nyitva van,
    az elj�r�s nem haszn�lhat�. Ilyenkor 
    kurzor_hasznalatban kiv�tel v�lt�dik ki.
  */
  PROCEDURE lejart_konyvek
  IS
  BEGIN
    IF cur_lejart_kolcsonzesek%ISOPEN THEN
      raise_kurzor_hasznalatban;
    END IF;

    DBMS_OUTPUT.PUT_LINE(str('�gyf�l', 40) || ' ' || str('K�nyv', 50) 
      || ' ' || str('d�tum', 18) || 'napok');
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
    Kilist�zza a lej�rt k�lcs�nz�si rekordok k�z�l
    azokat, amelyek ma j�rtak le.

    Ha a cur_lejart_kolcsonzesek kurzor nyitva van,
    az elj�r�s nem haszn�lhat�. Ilyenkor 
    kurzor_hasznalatban kiv�tel v�lt�dik ki.
  */
  PROCEDURE mai_lejart_konyvek
  IS
  BEGIN
    IF cur_lejart_kolcsonzesek%ISOPEN THEN
      raise_kurzor_hasznalatban;
    END IF;

    DBMS_OUTPUT.PUT_LINE(str('�gyf�l', 40) || ' ' || str('K�nyv', 50) 
      || ' ' || str('d�tum', 18) || 'napok');
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
     Megadja egy k�lcs�nz�tt k�nyv h�tralev� k�lcs�nz�si idej�t.

     hibas_argumentum kiv�telt v�lt ki, ha nincs ilyen k�lcs�nz�s.
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

    /* Lev�gjuk a d�tumokb�l az �ra r�szt. */
    v_Datum := TRUNC(v_Datum, 'DD');
    v_Most  := TRUNC(SYSDATE, 'DD');

    /* Visszaadjuk a k�l�nbs�get. */
    RETURN (v_Hosszabbitva + 1) * 30 + v_Datum - v_Most;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      raise_hibas_argumentum;
  END hatralevo_napok;


  /*******************************************************************/
  /* A csomag haszn�lat�ra vonatkoz� statisztik�t kezel� alprogramok */
  /*******************************************************************/

  /*
    Megadja a statisztik�t a legut�bbi null�z�s, ill.
    az indul�s �ta.
  */
  FUNCTION statisztika RETURN t_statisztika_rec
  IS
  BEGIN 
    RETURN v_Stat;
  END statisztika;

  /*
    Ki�rja a statisztik�t a legut�bbi null�z�s ill.
    az indul�s �ta.
  */
  PROCEDURE print_statisztika
  IS
  BEGIN 
    DBMS_OUTPUT.PUT_LINE('Statisztika a munkamenetben:');
    DBMS_OUTPUT.NEW_LINE;
    DBMS_OUTPUT.PUT_LINE(RPAD('Regisztr�lt �j �gyfelek sz�ma:', 40)
      || v_Stat.uj_ugyfelek);
    DBMS_OUTPUT.PUT_LINE(RPAD('Regisztr�lt �j k�nyvek sz�ma:', 40)
      || v_Stat.uj_konyvek);
    DBMS_OUTPUT.PUT_LINE(RPAD('K�lcs�nz�sek sz�ma:', 40)
      || v_Stat.kolcsonzesek);
    DBMS_OUTPUT.PUT_LINE(RPAD('Visszahozott k�nyvek sz�ma:', 40)
      || v_Stat.visszahozott_konyvek);

    DBMS_OUTPUT.PUT_LINE(RPAD('Utols� m�dos�t�s: ', 40) 
      || TO_CHAR(v_Stat.utolso_modositas, 'YYYY-MON-DD HH24:MI:SS'));
    DBMS_OUTPUT.PUT_LINE(RPAD('Statisztika kezdete: ', 40)
      || TO_CHAR(v_Stat.utolso_nullazas, 'YYYY-MON-DD HH24:MI:SS'));
  END print_statisztika;
  
  /*
    Null�zza a statiszik�t.
  */
  PROCEDURE statisztika_nullaz
  IS
    v_Stat2     t_statisztika_rec;
  BEGIN 
    v_Stat := v_Stat2;
  END statisztika_nullaz;


/********************************/
/* A csomag inicializ�l� r�sze. */
/********************************/
BEGIN
  statisztika_nullaz;  
END konyvtar_csomag;
/
show errors
