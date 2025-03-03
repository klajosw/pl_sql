/*
   A k�vetkez�kben megadunk egy elj�r�st, amely
   adminisztr�lja egy k�nyv k�lcs�nz�s�t. A k�lcsonz�s sikeres,
   ha van szabad p�d�ny a k�nyvb�l �s a felhszn�l� m�g k�lcs�n�zhet 
   k�nyvet. Egy�bk�nt a k�lcs�nz�s nem sikeres �s a hiba ok�t
   ki�rjuk.
  
   Az elj�r�s haszn�lat�t a tartalmaz� blokk demonstr�lja.
*/

DECLARE

  PROCEDURE kolcsonoz(
    p_Ugyfel_id    ugyfel.id%TYPE, 
    p_Konyv_id     konyv.id%TYPE, 
    p_Megjegyzes   kolcsonzes.megjegyzes%TYPE
  ) IS
    -- A k�nyvb�l ennyi szabad p�ld�ny van.
    v_Szabad            konyv.szabad%TYPE;
  
    -- Az �gyf�ln�l lev� k�nyvek sz�ma
    v_Kolcsonzott       PLS_INTEGER;
    -- Az �gyf�l �ltal maximum k�lcs�n�zhet� k�nyvek sz�ma
    v_Max_konyv         ugyfel.max_konyv%TYPE;
  
    v_Datum             kolcsonzes.datum%TYPE;
  
  BEGIN
    DBMS_OUTPUT.NEW_LINE;
    DBMS_OUTPUT.PUT_LINE('K�lcs�nz�s - �gyf�l id: ' || p_Ugyfel_id
      || ', k�nyv id: ' || p_Konyv_id || '.');
    -- Van-e szabad p�ld�ny a k�nyvb�l?
    SELECT szabad 
      INTO v_Szabad 
      FROM konyv
      WHERE id = p_Konyv_id;

    IF v_Szabad = 0 THEN
      DBMS_OUTPUT.PUT_LINE('Hiba! A k�nyv minden p�ld�nya ki van k�lcs�n�zve.');
      RETURN;
    END IF;
   
    -- K�lcs�n�zhet m�g az �gyf�l k�nyvet?
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
      DBMS_OUTPUT.PUT_LINE('Hiba! Az �gyf�l nem k�lcs�n�zhet t�bb k�nyvet.');
      RETURN;
    END IF;
    
    -- A k�lcs�nz�snek nincs akad�lya
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
    DBMS_OUTPUT.PUT_LINE('Sikeres k�lcs�nz�s.');
  END kolcsonoz;

BEGIN
  /* 
    T�th L�szl� (20) k�lcs�nzi a 'Java - start!' c�m� k�nyvet (25).
  */
  kolcsonoz(20, 25, NULL);

  /* 
    J�zsef Istv�n (15) k�lcs�nzi a 'A teljess�g fel�' c�m� k�nyvet (10).
    Nem siker�l, mert az �gyf�l m�r a maxim�lis sz�m� k�nyvet k�lcs�nzi.
  */
  kolcsonoz(15, 10, NULL);

  /* 
    Komor �gnes (30) k�lcs�nzi a 'A critical introduction...' c�m� k�nyvet (35).
    Nem siker�l, mert a k�nyvb�l m�r nincs szabad p�ld�ny.
  */
  kolcsonoz(30, 35, NULL);
END;
/

/*
Eredm�ny:

K�lcs�nz�s - �gyf�l id: 20, k�nyv id: 25.
Sikeres k�lcs�nz�s.

K�lcs�nz�s - �gyf�l id: 15, k�nyv id: 10.
Hiba! Az �gyf�l nem k�lcs�n�zhet t�bb k�nyvet.

K�lcs�nz�s - �gyf�l id: 30, k�nyv id: 35.
Hiba! A k�nyv minden p�ld�nya ki van k�lcs�n�zve.

A PL/SQL elj�r�s sikeresen befejez�d�tt.
*/
