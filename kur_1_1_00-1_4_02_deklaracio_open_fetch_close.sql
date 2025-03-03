DECLARE
  /* Megadja az �gyfeleket �b�c� sorrendben. 
     Van RETURN utas�t�sr�sz. */
  CURSOR cur_ugyfelek RETURN ugyfel%ROWTYPE IS
    SELECT * FROM ugyfel
      ORDER BY UPPER(nev);

  v_Uid    ugyfel.id%TYPE;

  /* Megadja annak az �gyf�lnek nev�t �s telefonsz�m�t, melynek
     azonos�t�j�t egy blokkbeli v�ltoz� tartalmazza. 
     Nincs RETURN utas�t�sr�sz, hisz a k�rd�sb�l ez �gyis kider�l. */
  CURSOR cur_ugyfel1 IS
    SELECT nev, tel_szam FROM ugyfel 
      WHERE id = v_Uid;

  /* Megadja a param�terk�nt �tadott azonos�t�val
     rendelkez� �gyfelet. Ha nincs param�ter, akkor
     a megadott kezd��rt�k �rv�nyes. */
  CURSOR cur_ugyfel2(p_Uid ugyfel.id%TYPE DEFAULT v_Uid) IS
    SELECT * FROM ugyfel 
      WHERE id = p_Uid;

  /* Megadja az adott d�tum szerint lej�rt
     k�lcs�nz�sekhez az �gyf�l nev�t, a k�nyv c�m�t,
     valamint a lej�rat �ta eltelt napok sz�m�nak
     eg�sz r�sz�t. 
     Ha nem adunk meg d�tumot, akkor az aktu�lis
     d�tum lesz a kezdeti �rt�k. */
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

  /* Egy megfelel� t�pus� v�ltoz�ba lehet majd a kurzor sorait bet�lteni */
  v_Lejart       cur_lejart_kolcsonzesek%ROWTYPE; 
  v_Nev          v_Lejart.nev%TYPE;

  /* Lek�rdezi �s z�rolja az adott azonos�t�j� k�nyv sor�t.
     Nem az eg�sz t�bl�t z�rolja, csak az akt�v halmaz elemeit!
     Erre akkor lehet p�ld�ul sz�ks�g, ha egy k�nyv k�lcs�nz�s�n�l
     ellen�r�zz�k, hogy biztosan van-e m�g p�ld�ny.
     �gy biztosan nem lesz gond. ha k�t k�lcs�nz�s egyszerre t�rt�nik
     ugyanarra k�nyvre. Az egyik biztosan bev�rja a m�sikat. */
  CURSOR cur_konyvzarolo(p_Kid konyv.id%TYPE) IS
    SELECT * FROM konyv
      WHERE id = p_Kid
      FOR UPDATE OF cim;

  /* K�s�rletet tesz az adott k�nyv z�rol�s�ra.
     Ha az er�forr�st foglalts�ga miatt nem
     lehet megnyitni, ORA-00054 kiv�tel v�lt�dik ki. */
  CURSOR cur_konyvzarolo2(p_Kid konyv.id%TYPE) IS
    SELECT * FROM konyv
      WHERE id = p_Kid
      FOR UPDATE NOWAIT;

  /* Ezek a v�ltoz�k kompatibilisek az el�z� kurzorokkal.
     D�ntse el, melyik kurzor melyik v�ltoz�val kompatibilis! */
  v_Ugyfel      ugyfel%ROWTYPE;  
  v_Konyv       konyv%ROWTYPE;  
  v_Unev        ugyfel.nev%TYPE;
  v_Utel_szam   ugyfel.tel_szam%TYPE;

BEGIN
  v_Uid := 15;  -- J�zsef Istv�n �gyf�l azonos�t�ja

  /* Mely sorok lesznek az akt�v halmaz elemei ? */
  OPEN cur_ugyfel1; 
  OPEN cur_ugyfel2(15);

  LOOP
    FETCH cur_ugyfel1 INTO v_Unev, v_Utel_szam;
    EXIT WHEN cur_ugyfel1%NOTFOUND;

    /* Itt j�n a feldolgoz�s, ki�ratjuk a neveket. */
    DBMS_OUTPUT.PUT_LINE(v_Unev || ', ' || v_Utel_szam);
  END LOOP;

  CLOSE cur_ugyfel1;
  CLOSE cur_ugyfel2;
  DBMS_OUTPUT.NEW_LINE;

  /* Mivel a param�ter mindig IN t�pus�, 
     kifejez�s is lehet aktu�lis param�ter. */
  OPEN cur_lejart_kolcsonzesek(TO_DATE('02-M�J.  -09'));
  BEGIN
    OPEN cur_lejart_kolcsonzesek; -- CURSOR_ALREADY_OPEN kiv�telt v�lt ki!
  EXCEPTION
    WHEN CURSOR_ALREADY_OPEN THEN
      DBMS_OUTPUT.PUT_LINE('Hiba: ' || SQLERRM);
  END;

  v_Nev := NULL;
  LOOP
    FETCH cur_lejart_kolcsonzesek INTO v_Lejart;
    EXIT WHEN cur_lejart_kolcsonzesek%NOTFOUND;

    /* J�het a feldolgoz�s, mondjuk figyelmeztet� e-mail k�ld�se.
       Most csak ki�rjuk az egyes nevekhez a lej�rt k�nyveket. */
    IF v_Nev IS NULL OR v_Nev <> v_Lejart.nev THEN
      v_Nev := v_Lejart.nev;
      DBMS_OUTPUT.NEW_LINE;
      DBMS_OUTPUT.PUT_LINE('�gyf�l: ' || v_Nev);
    END IF;
    DBMS_OUTPUT.PUT_LINE('   ' || v_Lejart.napok || ' nap, ' 
      || v_Lejart.cim);
  END LOOP;

  CLOSE cur_lejart_kolcsonzesek;
END;
/

/*
Eredm�ny:

J�zsef Istv�n, 06-52-456654

Hiba: ORA-06511: PL/SQL: a kurzor m�r meg van nyitva

�gyf�l: Jaripekka H�m�lainen
   22 nap, A critical introduction to twentieth-century American drama - Volume 2
   22 nap, The Norton Anthology of American Literature - Second Edition - Volume 2

�gyf�l: J�zsef Istv�n
   17 nap, ECOOP 2001 - Object-Oriented Programming
   17 nap, Piszkos Fred �s a t�bbiek

A PL/SQL elj�r�s sikeresen befejez�d�tt.
*/
