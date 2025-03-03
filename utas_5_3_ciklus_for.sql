/* For 1 - Egy egyszer� FOR ciklus */
DECLARE
  v_Osszeg PLS_INTEGER;
BEGIN
  v_Osszeg := 0;
  FOR i IN 1..100 LOOP
    v_Osszeg := v_Osszeg + i;
  END LOOP;

  DBMS_OUTPUT.PUT_LINE('Gauss m�r gyerekkor�ban k�nnyen kisz�molta, hogy');
  DBMS_OUTPUT.PUT_LINE(' 1 + 2 + ... + 100 = ' || v_Osszeg || '.');
END;
/

/* For 2 - REVERSE haszn�lata */
BEGIN
  DBMS_OUTPUT.PUT_LINE('Gauss �gy �rta egym�s al� a sz�mokat (most csak 1-10):');

  FOR i IN 1..10 LOOP
    DBMS_OUTPUT.PUT(RPAD(i, 4));
  END LOOP;
  DBMS_OUTPUT.NEW_LINE;

  FOR i IN REVERSE 1..10 LOOP
    DBMS_OUTPUT.PUT(RPAD(i, 4));
  END LOOP;
  DBMS_OUTPUT.NEW_LINE;

  FOR i IN REVERSE 1..10 LOOP
    DBMS_OUTPUT.PUT(RPAD('--', 4));
  END LOOP;
  DBMS_OUTPUT.NEW_LINE;

  FOR i IN REVERSE 1..10 LOOP
    DBMS_OUTPUT.PUT(RPAD(11, 4));
  END LOOP;
  DBMS_OUTPUT.NEW_LINE;
END;
/

/* For 3 - "FOR Elise" - Egy kis esettanulm�ny */
<<cimke>>
DECLARE
  i VARCHAR2(10) := 'Almafa';
  j INTEGER;

BEGIN
  /*
     A p�ld�t �gy pr�b�lja ki, hogy j-re n�zve mindig csak egy �rt�kad�s
     t�rt�njen. Ekkor igaz lesz az �rt�kad�s el�tti megjegyz�s.
  */

  -- A hat�rok egyike sem lehet NULL, a ciklusfejben j ki�rt�kel�se
  -- VALUE_ERROR kiv�telt eredm�nyez.
  j := NULL;

  -- Az als� hat�r nagyobb a fels� hat�rn�l, �res a tartom�ny,
  -- a ciklusmag nem fut le egyszer sem.
  j := 0;

  -- Az als� �s a fels� hat�r megegyezik, a ciklusmag egyszer fut le.
  j := 1;

  -- Az als� hat�r kisebb a fels� hat�rn�l,
  -- a ciklusmag jelen esetben j-1+1 = 10-szer fut le.
  j := 10;

  -- T�l nagy sz�m. A PLS_INTEGER tartom�ny�ba nem f�r bele,
  -- �gy kivetelt kapunk a ciklusfejben.
  j := 2**32;


  -- Az i ciklusv�ltoz� implicit deklar�ci�ja elfedi
  -- az i explicit deklar�ci�j�t
  FOR i IN 1..j
  LOOP
    -- a ciklusv�ltoz� szerepelhet kifejez�sben
    DBMS_OUTPUT.PUT_LINE(i*2); 

    -- hib�s, a ciklusv�ltoz� neves�tett konstansk�nt viselkedik
    i := i + 1;

    -- Az elfedett v�ltoz�ra min�s�t�ssel hivatkozhatunk.
    DBMS_OUTPUT.PUT_LINE(cimke.i);
    cimke.i := 'K�rtefa'; -- szab�lyos, ez a blokk elej�n deklar�lt i
  END LOOP;

  -- Az explicit m�don deklar�lt i �jra el�rhet� min�s�t�s n�lk�l
  DBMS_OUTPUT.PUT_LINE(i);
END;
/
