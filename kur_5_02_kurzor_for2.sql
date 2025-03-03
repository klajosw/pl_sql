BEGIN
  /* Explicit kurzor helyett SQL-lek�rdez�st is haszn�lhatunk. 
     Ilyenkor egy rejtett kurzor keletkezik, ami a programoz� sz�m�ra
     hozz�f�rhetetlen, azaz az implicit attrib�tumok nem
     adnak r�la inform�ci�t. */
  FOR v_Ugyfel IN (SELECT * FROM ugyfel) LOOP
    DBMS_OUTPUT.PUT_LINE(v_Ugyfel.id || ', ' || v_Ugyfel.nev);
    IF SQL%ROWCOUNT IS NOT NULL THEN
      /* Ide NEM ker�l a vez�rl�s, mert a SQL%ROWCOUNT NULL. */
      DBMS_OUTPUT.PUT_LINE('SQL%ROWCOUNT: ' || SQL%ROWCOUNT);
    END IF;
  END LOOP;
END;
/

/*
Eredm�ny:

5, Kov�cs J�nos
10, Szab� M�t� Istv�n
15, J�zsef Istv�n
20, T�th L�szl�
25, Erdei Anita
30, Komor �gnes
35, Jaripekka H�m�lainen

A PL/SQL elj�r�s sikeresen befejez�d�tt.

*/
