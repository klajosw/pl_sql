DECLARE

  /* Kísérletet tesz az adott könyv zárolására.
     Ha az erõforrást foglaltsága miatt nem
     lehet megnyitni, ORA-00054 kivétel váltódik ki. */
  CURSOR cur_konyvzarolo2(p_Kid konyv.id%TYPE) IS
    SELECT * FROM konyv
      WHERE id = p_Kid
      FOR UPDATE NOWAIT;

  probak    NUMBER;
  t         NUMBER;

  foglalt   EXCEPTION;
  PRAGMA EXCEPTION_INIT(foglalt, -54);

BEGIN
  probak := 0;
  
  /* Legfeljebb 10-szer próbáljuk megnyitni. */

  DBMS_OUTPUT.PUT_LINE(SYSTIMESTAMP);
  WHILE probak < 10 LOOP
    probak := probak + 1;

    BEGIN
      OPEN cur_konyvzarolo2(15);
      -- Sikerült! Kilépünk a ciklusból
      EXIT; 

    EXCEPTION
      WHEN foglalt THEN
        NULL;
    END;

    /* Várunk kb. 10 ms-t. */
    t := TO_CHAR(SYSTIMESTAMP, 'SSSSSFF');
    WHILE t + 10**8 > TO_CHAR(SYSTIMESTAMP, 'SSSSSFF') LOOP
      NULL; 
    END LOOP;

  END LOOP;
  DBMS_OUTPUT.PUT_LINE(SYSTIMESTAMP);
  DBMS_OUTPUT.PUT_LINE('A kurzort ' 
    || CASE cur_konyvzarolo2%ISOPEN WHEN TRUE THEN '' ELSE 'nem ' END 
    || 'sikerült megnyitni.');

  IF cur_konyvzarolo2%ISOPEN THEN 
    CLOSE cur_konyvzarolo2;
  END IF;

END;
/

/*
Próbálja ki a blokkot a következõ 2 szituációban:
a.,
  Egyetlen munkamenettel kapcsolódjon az adatbázishoz.
  Futtassa le a blokkot.
  Mit tapasztal?

b.,
  Két munkamenettel kapcsolódjon az adatbázishoz, 
  például úgy, hogy két SQL*Plus-szal kapcsolódik.
  Az egyikben módosítsa a konyv tábla sorát:
    UPDATE konyv SET cim = 'Próba' WHERE id = 15;
  A másik munkamenetben futtassa le a blokkot!
  Mit tapasztal?
  
  Ezután az elsõ munkamenetben adjon ki egy ROLLBACK 
  parancsot, a másik munkamenetben pedig futtassa le
  ismét a blokkot!
  Mit tapasztal?

*/
