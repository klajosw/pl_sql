DECLARE

  /* K�s�rletet tesz az adott k�nyv z�rol�s�ra.
     Ha az er�forr�st foglalts�ga miatt nem
     lehet megnyitni, ORA-00054 kiv�tel v�lt�dik ki. */
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
  
  /* Legfeljebb 10-szer pr�b�ljuk megnyitni. */

  DBMS_OUTPUT.PUT_LINE(SYSTIMESTAMP);
  WHILE probak < 10 LOOP
    probak := probak + 1;

    BEGIN
      OPEN cur_konyvzarolo2(15);
      -- Siker�lt! Kil�p�nk a ciklusb�l
      EXIT; 

    EXCEPTION
      WHEN foglalt THEN
        NULL;
    END;

    /* V�runk kb. 10 ms-t. */
    t := TO_CHAR(SYSTIMESTAMP, 'SSSSSFF');
    WHILE t + 10**8 > TO_CHAR(SYSTIMESTAMP, 'SSSSSFF') LOOP
      NULL; 
    END LOOP;

  END LOOP;
  DBMS_OUTPUT.PUT_LINE(SYSTIMESTAMP);
  DBMS_OUTPUT.PUT_LINE('A kurzort ' 
    || CASE cur_konyvzarolo2%ISOPEN WHEN TRUE THEN '' ELSE 'nem ' END 
    || 'siker�lt megnyitni.');

  IF cur_konyvzarolo2%ISOPEN THEN 
    CLOSE cur_konyvzarolo2;
  END IF;

END;
/

/*
Pr�b�lja ki a blokkot a k�vetkez� 2 szitu�ci�ban:
a.,
  Egyetlen munkamenettel kapcsol�djon az adatb�zishoz.
  Futtassa le a blokkot.
  Mit tapasztal?

b.,
  K�t munkamenettel kapcsol�djon az adatb�zishoz, 
  p�ld�ul �gy, hogy k�t SQL*Plus-szal kapcsol�dik.
  Az egyikben m�dos�tsa a konyv t�bla sor�t:
    UPDATE konyv SET cim = 'Pr�ba' WHERE id = 15;
  A m�sik munkamenetben futtassa le a blokkot!
  Mit tapasztal?
  
  Ezut�n az els� munkamenetben adjon ki egy ROLLBACK 
  parancsot, a m�sik munkamenetben pedig futtassa le
  ism�t a blokkot!
  Mit tapasztal?

*/
