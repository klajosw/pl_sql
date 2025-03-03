BEGIN
  /* Explicit kurzor helyett SQL-lekérdezést is használhatunk. 
     Ilyenkor egy rejtett kurzor keletkezik, ami a programozó számára
     hozzáférhetetlen, azaz az implicit attribútumok nem
     adnak róla információt. */
  FOR v_Ugyfel IN (SELECT * FROM ugyfel) LOOP
    DBMS_OUTPUT.PUT_LINE(v_Ugyfel.id || ', ' || v_Ugyfel.nev);
    IF SQL%ROWCOUNT IS NOT NULL THEN
      /* Ide NEM kerül a vezérlés, mert a SQL%ROWCOUNT NULL. */
      DBMS_OUTPUT.PUT_LINE('SQL%ROWCOUNT: ' || SQL%ROWCOUNT);
    END IF;
  END LOOP;
END;
/

/*
Eredmény:

5, Kovács János
10, Szabó Máté István
15, József István
20, Tóth László
25, Erdei Anita
30, Komor Ágnes
35, Jaripekka Hämälainen

A PL/SQL eljárás sikeresen befejezõdött.

*/
