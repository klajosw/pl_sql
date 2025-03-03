/*
   A könyvtár úgy döntött, hogy minden olyan
   ügyfele, aki már több mint egy éve iratkozott be,
   legalább 10 könyvet kölcsönözhet.
   Szeretnénk elvégezni a szükséges változtatásokat úgy,
   hogy a változásokról feljegyzésünk legyen egy szöveges
   állományban.

   A megoldásunk egy olyan PL/SQL blokk, amely elvégzi a 
   változtatásokat és közben ezekrõl információt ír
   a képernyõre. Így az eredmény elmenthetõ (spool).

   A program nem tartalmaz tranzakciókezelõ utasításokat,
   így a változtatott sorok a legközelebbi ROLLBACK vagy
   COMMIT utasításig zárolva lesznek.
*/

DECLARE

  /* Az ügyfelek lekérdezése. */
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
  DBMS_OUTPUT.PUT_LINE('Kölcsönzési kvóta emelése');
  DBMS_OUTPUT.PUT_LINE('-------------------------');

  /* A példa kedvéért rögzítjük a mai dátum értékét. */
  v_Ma := TO_DATE('2002-05-02 09:01:12', 'YYYY-MM-DD HH24:MI:SS');
  OPEN cur_ugyfelek(v_Ma);

  LOOP
    FETCH cur_ugyfelek INTO v_Ugyfel;
    EXIT WHEN cur_ugyfelek%NOTFOUND;

    /* A módosítandó rekordot a kurzorral azonosítjuk. */
    UPDATE ugyfel SET max_konyv = 10
      WHERE CURRENT OF cur_ugyfelek;

    DBMS_OUTPUT.PUT_LINE(cur_ugyfelek%ROWCOUNT
      || ', ügyfél: ' || v_Ugyfel.id || ', ' || v_Ugyfel.nev
      || ', beíratkozott: ' || TO_CHAR(v_Ugyfel.beiratkozas, 'YYYY-MON-DD')
      || ', régi érték: ' || v_Ugyfel.max_konyv || ', új érték: 10');

    v_Sum := v_Sum + 10 - v_Ugyfel.max_konyv;
  END LOOP;

  DBMS_OUTPUT.PUT_LINE('-------------------------');
  DBMS_OUTPUT.PUT_LINE('Összesen ' || cur_ugyfelek%ROWCOUNT 
    || ' ügyfél adata változott meg.');
  DBMS_OUTPUT.PUT_LINE('így ügyfeleink összesen ' || v_Sum
    || ' könyvvel kölcsönözhetnek többet ezután.');
  DBMS_OUTPUT.PUT_LINE('Dátum: ' 
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
Eredmény (elsõ alkalommal, rögzítettük a  mai dátumot: 2002. május 2.):

Kölcsönzési kvóta emelése
-------------------------
1, ügyfél: 25, Erdei Anita, beíratkozott: 1997-DEC.  -05, régi érték: 5, új érték: 10
2, ügyfél: 30, Komor Ágnes, beíratkozott: 2000-JÚN.  -11, régi érték: 5, új érték: 10
3, ügyfél: 20, Tóth László, beíratkozott: 1996-ÁPR.  -01, régi érték: 5, új érték: 10
-------------------------
Összesen 3 ügyfél adata változott meg.
így ügyfeleink összesen 15 könyvvel kölcsönözhetnek többet ezután.
Dátum: 2002-MÁJ.  -02 09:01:12

A PL/SQL eljárás sikeresen befejezõdött.

*/
