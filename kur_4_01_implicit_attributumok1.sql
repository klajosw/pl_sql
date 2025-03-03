BEGIN
  /* Az SQL-kurzor attrib�tumai, az SQL%ISOPEN kiv�tel�vel
     NULL-t adnak vissza els� h�v�skor. */
  IF SQL%FOUND IS NULL 
     AND SQL%NOTFOUND IS NULL AND SQL%ROWCOUNT IS NULL THEN
    DBMS_OUTPUT.PUT_LINE('Az attrib�tumok NULL-t adtak.');
  END IF;

  IF NOT SQL%ISOPEN THEN
    DBMS_OUTPUT.PUT_LINE('Az SQL%ISOPEN hamis.');
  END IF;

  /* N�h�ny k�nyvb�l ut�np�tl�st kapott a k�nyvt�r. */
  UPDATE konyv SET keszlet = keszlet + 5, szabad = szabad + 5
    WHERE id IN (45, 50);
  IF (SQL%FOUND) THEN
    DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT || ' rekord m�dos�tva.');
  ELSE
    DBMS_OUTPUT.PUT_LINE('Nincsenek ilyen k�nyveink.');
  END IF;

  /* Most nem l�tez� k�nyveket adunk meg. */
  UPDATE konyv SET keszlet = keszlet + 5, szabad = szabad + 5
    WHERE id IN (-45, -50);
  IF (SQL%FOUND) THEN
    DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT || ' rekord m�dos�tva.');
  ELSE
    DBMS_OUTPUT.PUT_LINE('Nincsenek ilyen k�nyveink.');
  END IF;

  DECLARE
    i   NUMBER;
  BEGIN
    /* Ez bizony sok lesz. */
    SELECT id INTO i FROM ugyfel
      WHERE id = id;
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('SQL%ROWCOUNT: ' || SQL%ROWCOUNT);
  END;

  DECLARE
    i   NUMBER;
  BEGIN
    /* Iyen nem lesz. */
    SELECT id INTO i FROM ugyfel 
      WHERE id < 0;
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('SQL%ROWCOUNT: ' || SQL%ROWCOUNT);
  END;

END;
/

/*
Eredm�ny:

Az attrib�tumok NULL-t adtak.
Az SQL%ISOPEN hamis.
2 rekord m�dos�tva.
Nincsenek ilyen k�nyveink.
SQL%ROWCOUNT: 1
SQL%ROWCOUNT: 0

A PL/SQL elj�r�s sikeresen befejez�d�tt.

*/
