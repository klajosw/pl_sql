BEGIN
  /* Az SQL-kurzor attribútumai, az SQL%ISOPEN kivételével
     NULL-t adnak vissza elsõ híváskor. */
  IF SQL%FOUND IS NULL 
     AND SQL%NOTFOUND IS NULL AND SQL%ROWCOUNT IS NULL THEN
    DBMS_OUTPUT.PUT_LINE('Az attribútumok NULL-t adtak.');
  END IF;

  IF NOT SQL%ISOPEN THEN
    DBMS_OUTPUT.PUT_LINE('Az SQL%ISOPEN hamis.');
  END IF;

  /* Néhány könyvbõl utánpótlást kapott a könyvtár. */
  UPDATE konyv SET keszlet = keszlet + 5, szabad = szabad + 5
    WHERE id IN (45, 50);
  IF (SQL%FOUND) THEN
    DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT || ' rekord módosítva.');
  ELSE
    DBMS_OUTPUT.PUT_LINE('Nincsenek ilyen könyveink.');
  END IF;

  /* Most nem létezõ könyveket adunk meg. */
  UPDATE konyv SET keszlet = keszlet + 5, szabad = szabad + 5
    WHERE id IN (-45, -50);
  IF (SQL%FOUND) THEN
    DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT || ' rekord módosítva.');
  ELSE
    DBMS_OUTPUT.PUT_LINE('Nincsenek ilyen könyveink.');
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
Eredmény:

Az attribútumok NULL-t adtak.
Az SQL%ISOPEN hamis.
2 rekord módosítva.
Nincsenek ilyen könyveink.
SQL%ROWCOUNT: 1
SQL%ROWCOUNT: 0

A PL/SQL eljárás sikeresen befejezõdött.

*/
