DECLARE
  TYPE t_Konyv_rec IS RECORD (
    id      konyv.id%TYPE,
    cim     konyv.cim%TYPE
  );
  
  TYPE t_konyvref IS REF CURSOR RETURN t_Konyv_rec;

  /* Lek�rdezz�k az �gyfeleket �s a k�lcs�nz�tt k�nyveiket,
     azt az �gyf�lt is, akin�l nincs k�nyv. 
     A k�nyveket egy CURSOR-kifejez�s seg�ts�g�vel adjuk vissza. */
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
    DBMS_OUTPUT.PUT_LINE('�gyf�l: ' || v_Uid || ', ' || v_Unev);
                                  
    /* Most a be�gyazott kurzor elemeit �rjuk ki, ha nem �res.
       A be�gyazott kurzort nem kell k�l�n megnyitni �s lez�rni sem. */
    FETCH v_Konyvek INTO v_Konyv;
    IF v_Konyvek%FOUND THEN
      DBMS_OUTPUT.PUT_LINE('  A k�lcs�nz�tt k�nyvek:');
      WHILE v_Konyvek%FOUND LOOP
        DBMS_OUTPUT.PUT_LINE('    ' || v_Konyv.id || ', ' || v_Konyv.cim);
        FETCH v_Konyvek INTO v_Konyv;
      END LOOP;
    ELSE
      DBMS_OUTPUT.PUT_LINE('  jelenleg nem k�lcs�n�z k�nyvet.');

    END IF;
  END LOOP;

  CLOSE cur_ugyfel_konyv;
END;
/

/*
Eredm�ny:

�gyf�l: 25, Erdei Anita
  A k�lcs�nz�tt k�nyvek:
    35, A critical introduction to twentieth-century American drama - Volume 2

�gyf�l: 35, Jaripekka H�m�lainen
  A k�lcs�nz�tt k�nyvek:
    35, A critical introduction to twentieth-century American drama - Volume 2
    40, The Norton Anthology of American Literature - Second Edition - Volume 2

�gyf�l: 15, J�zsef Istv�n
  A k�lcs�nz�tt k�nyvek:
    15, Piszkos Fred �s a t�bbiek
    20, ECOOP 2001 - Object-Oriented Programming
    25, Java - start!
    45, Matematikai zseblexikon
    50, Matematikai K�zik�nyv

�gyf�l: 30, Komor �gnes
  A k�lcs�nz�tt k�nyvek:
    5, A r�mai jog t�rt�nete �s instit�ci�i
    10, A teljess�g fel�

�gyf�l: 5, Kov�cs J�nos
  jelenleg nem k�lcs�n�z k�nyvet.

�gyf�l: 10, Szab� M�t� Istv�n
  A k�lcs�nz�tt k�nyvek:
    30, SQL:1999 Understanding Relational Language Components
    45, Matematikai zseblexikon
    50, Matematikai K�zik�nyv

�gyf�l: 20, T�th L�szl�
  A k�lcs�nz�tt k�nyvek:
    30, SQL:1999 Understanding Relational Language Components

A PL/SQL elj�r�s sikeresen befejez�d�tt.
*/
