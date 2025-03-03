/*
   A k�nyvt�r �gy d�nt�tt, hogy minden olyan
   �gyfele, aki m�r t�bb mint egy �ve iratkozott be,
   legal�bb 10 k�nyvet k�lcs�n�zhet.
   Szeretn�nk elv�gezni a sz�ks�ges v�ltoztat�sokat �gy,
   hogy a v�ltoz�sokr�l feljegyz�s�nk legyen egy sz�veges
   �llom�nyban.

   A megold�sunk egy olyan PL/SQL blokk, amely elv�gzi a 
   v�ltoztat�sokat �s k�zben ezekr�l inform�ci�t �r
   a k�perny�re. �gy az eredm�ny elmenthet� (spool).

   A program nem tartalmaz tranzakci�kezel� utas�t�sokat,
   �gy a v�ltoztatott sorok a legk�zelebbi ROLLBACK vagy
   COMMIT utas�t�sig z�rolva lesznek.
*/

DECLARE

  /* Az �gyfelek lek�rdez�se. */
  CURSOR cur_ugyfelek(p_Datum DATE DEFAULT SYSDATE) IS
    SELECT * FROM ugyfel
      WHERE p_Datum - beiratkozas >= 365
        AND max_konyv < 10
      ORDER BY UPPER(nev)
      FOR UPDATE OF max_konyv;

  v_Ugyfel       cur_ugyfelek%ROWTYPE;
  v_Ma           DATE;
  v_Sum          NUMBER := 0;

BEGIN
  DBMS_OUTPUT.PUT_LINE('K�lcs�nz�si kv�ta emel�se');
  DBMS_OUTPUT.PUT_LINE('-------------------------');

  /* A p�lda kedv��rt r�gz�tj�k a mai d�tum �rt�k�t. */
  v_Ma := TO_DATE('2002-05-02 09:01:12', 'YYYY-MM-DD HH24:MI:SS');
  OPEN cur_ugyfelek(v_Ma);

  LOOP
    FETCH cur_ugyfelek INTO v_Ugyfel;
    EXIT WHEN cur_ugyfelek%NOTFOUND;

    /* A m�dos�tand� rekordot a kurzorral azonos�tjuk. */
    UPDATE ugyfel SET max_konyv = 10
      WHERE CURRENT OF cur_ugyfelek;

    DBMS_OUTPUT.PUT_LINE(cur_ugyfelek%ROWCOUNT
      || ', �gyf�l: ' || v_Ugyfel.id || ', ' || v_Ugyfel.nev
      || ', be�ratkozott: ' || TO_CHAR(v_Ugyfel.beiratkozas, 'YYYY-MON-DD')
      || ', r�gi �rt�k: ' || v_Ugyfel.max_konyv || ', �j �rt�k: 10');

    v_Sum := v_Sum + 10 - v_Ugyfel.max_konyv;
  END LOOP;

  DBMS_OUTPUT.PUT_LINE('-------------------------');
  DBMS_OUTPUT.PUT_LINE('�sszesen ' || cur_ugyfelek%ROWCOUNT 
    || ' �gyf�l adata v�ltozott meg.');
  DBMS_OUTPUT.PUT_LINE('�gy �gyfeleink �sszesen ' || v_Sum
    || ' k�nyvvel k�lcs�n�zhetnek t�bbet ezut�n.');
  DBMS_OUTPUT.PUT_LINE('D�tum: ' 
                       || TO_CHAR(v_Ma, 'YYYY-MON-DD HH24:MI:SS'));

  CLOSE cur_ugyfelek;

EXCEPTION
  WHEN OTHERS THEN
    IF cur_ugyfelek%ISOPEN THEN
      CLOSE cur_ugyfelek;
    END IF;
    RAISE;
END;
/

/*
Eredm�ny (els� alkalommal, r�gz�tett�k a  mai d�tumot: 2002. m�jus 2.):

K�lcs�nz�si kv�ta emel�se
-------------------------
1, �gyf�l: 25, Erdei Anita, be�ratkozott: 1997-DEC.  -05, r�gi �rt�k: 5, �j �rt�k: 10
2, �gyf�l: 30, Komor �gnes, be�ratkozott: 2000-J�N.  -11, r�gi �rt�k: 5, �j �rt�k: 10
3, �gyf�l: 20, T�th L�szl�, be�ratkozott: 1996-�PR.  -01, r�gi �rt�k: 5, �j �rt�k: 10
-------------------------
�sszesen 3 �gyf�l adata v�ltozott meg.
�gy �gyfeleink �sszesen 15 k�nyvvel k�lcs�n�zhetnek t�bbet ezut�n.
D�tum: 2002-M�J.  -02 09:01:12

A PL/SQL elj�r�s sikeresen befejez�d�tt.

*/
