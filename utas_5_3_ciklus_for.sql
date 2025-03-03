/* For 1 - Egy egyszerû FOR ciklus */
DECLARE
  v_Osszeg PLS_INTEGER;
BEGIN
  v_Osszeg := 0;
  FOR i IN 1..100 LOOP
    v_Osszeg := v_Osszeg + i;
  END LOOP;

  DBMS_OUTPUT.PUT_LINE('Gauss már gyerekkorában könnyen kiszámolta, hogy');
  DBMS_OUTPUT.PUT_LINE(' 1 + 2 + ... + 100 = ' || v_Osszeg || '.');
END;
/

/* For 2 - REVERSE használata */
BEGIN
  DBMS_OUTPUT.PUT_LINE('Gauss így írta egymás alá a számokat (most csak 1-10):');

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

/* For 3 - "FOR Elise" - Egy kis esettanulmány */
<<cimke>>
DECLARE
  i VARCHAR2(10) := 'Almafa';
  j INTEGER;

BEGIN
  /*
     A példát úgy próbálja ki, hogy j-re nézve mindig csak egy értékadás
     történjen. Ekkor igaz lesz az értékadás elõtti megjegyzés.
  */

  -- A határok egyike sem lehet NULL, a ciklusfejben j kiértékelése
  -- VALUE_ERROR kivételt eredményez.
  j := NULL;

  -- Az alsó határ nagyobb a felsõ határnál, üres a tartomány,
  -- a ciklusmag nem fut le egyszer sem.
  j := 0;

  -- Az alsó és a felsõ határ megegyezik, a ciklusmag egyszer fut le.
  j := 1;

  -- Az alsó határ kisebb a felsõ határnál,
  -- a ciklusmag jelen esetben j-1+1 = 10-szer fut le.
  j := 10;

  -- Túl nagy szám. A PLS_INTEGER tartományába nem fér bele,
  -- így kivetelt kapunk a ciklusfejben.
  j := 2**32;


  -- Az i ciklusváltozó implicit deklarációja elfedi
  -- az i explicit deklarációját
  FOR i IN 1..j
  LOOP
    -- a ciklusváltozó szerepelhet kifejezésben
    DBMS_OUTPUT.PUT_LINE(i*2); 

    -- hibás, a ciklusváltozó nevesített konstansként viselkedik
    i := i + 1;

    -- Az elfedett változóra minõsítéssel hivatkozhatunk.
    DBMS_OUTPUT.PUT_LINE(cimke.i);
    cimke.i := 'Körtefa'; -- szabályos, ez a blokk elején deklarált i
  END LOOP;

  -- Az explicit módon deklarált i újra elérhetõ minõsítés nélkül
  DBMS_OUTPUT.PUT_LINE(i);
END;
/
