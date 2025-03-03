DECLARE

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
  v_Nev          ugyfel.nev%TYPE;

BEGIN
  /* Hasonl�tsuk �ssze ezt a megold�st a kor�bbival!
     Vegy�k �szre, hogy a ciklusv�ltoz� implicit m�don van deklar�lva. */
  FOR v_Lejart IN cur_lejart_kolcsonzesek(TO_DATE('02-M�J.  -09')) LOOP
    /* Nincs FETCH �s %NOTFOUND-ra sincs sz�ks�g. */

    IF v_Nev IS NULL OR v_Nev <> v_Lejart.nev THEN
      v_Nev := v_Lejart.nev;
      DBMS_OUTPUT.NEW_LINE;
      DBMS_OUTPUT.PUT_LINE('�gyf�l: ' || v_Nev);
    END IF;
    DBMS_OUTPUT.PUT_LINE('   ' || v_Lejart.napok || ' nap, ' 
      || v_Lejart.cim);
  END LOOP;

  /* A kurzor m�r le van z�rva. */
END;
/

/*
Eredm�ny:

�gyf�l: Jaripekka H�m�lainen
   22 nap, A critical introduction to twentieth-century American drama - Volume 2
   22 nap, The Norton Anthology of American Literature - Second Edition - Volume 2

�gyf�l: J�zsef Istv�n
   17 nap, ECOOP 2001 - Object-Oriented Programming
   17 nap, Piszkos Fred �s a t�bbiek

A PL/SQL elj�r�s sikeresen befejez�d�tt.
*/
