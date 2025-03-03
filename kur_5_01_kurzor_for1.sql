DECLARE

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
  v_Nev          ugyfel.nev%TYPE;

BEGIN
  /* Hasonlítsuk össze ezt a megoldást a korábbival!
     Vegyük észre, hogy a ciklusváltozó implicit módon van deklarálva. */
  FOR v_Lejart IN cur_lejart_kolcsonzesek(TO_DATE('02-MÁJ.  -09')) LOOP
    /* Nincs FETCH és %NOTFOUND-ra sincs szükség. */

    IF v_Nev IS NULL OR v_Nev <> v_Lejart.nev THEN
      v_Nev := v_Lejart.nev;
      DBMS_OUTPUT.NEW_LINE;
      DBMS_OUTPUT.PUT_LINE('Ügyfél: ' || v_Nev);
    END IF;
    DBMS_OUTPUT.PUT_LINE('   ' || v_Lejart.napok || ' nap, ' 
      || v_Lejart.cim);
  END LOOP;

  /* A kurzor már le van zárva. */
END;
/

/*
Eredmény:

Ügyfél: Jaripekka Hämälainen
   22 nap, A critical introduction to twentieth-century American drama - Volume 2
   22 nap, The Norton Anthology of American Literature - Second Edition - Volume 2

Ügyfél: József István
   17 nap, ECOOP 2001 - Object-Oriented Programming
   17 nap, Piszkos Fred és a többiek

A PL/SQL eljárás sikeresen befejezõdött.
*/
