/* Blokk */
<<kulso>>
DECLARE
  s     VARCHAR2(30) := 'hal';
BEGIN

  /* beágyazott blokk */
  DECLARE
    s2  VARCHAR2(20) := 'El_lgató fej_lgató';
  BEGIN
    -- s2 is és s is látható
    DBMS_OUTPUT.PUT_LINE(s); -- 'hal'

    s := REPLACE(s2, '_', s);
    -- blokk vége
  END;

  DBMS_OUTPUT.PUT_LINE(s); -- 'Elhallgató fejhallgató'

  /* A következõ sor fordítási hibát eredményezne, mert s2 már nem látható.
  DBMS_OUTPUT.PUT_LINE(s2);
  */

  <<belso>>
  DECLARE
    s   NUMBER;  -- elfedi a külsõ blokkbeli deklarációt
  BEGIN
    s := 5;
    belso.s := 7;
    kulso.s := 'Almafa';

    GOTO ki;
    
    -- Ide soha nem kerülhet a vezérlés.
    DBMS_OUTPUT.PUT_LINE('Sikertelen GOTO ?!');
  END;    

  DBMS_OUTPUT.PUT_LINE(s); -- 'Almafa'

  <<ki>>
  BEGIN
    /* Ez az érték nem fér bele a változóba.
       VALUE_ERROR kivétel váltódik ki. */
    s := '1234567890ABCDEFGHIJ1234567890ABCDEFGHHIJ';

    -- A kivétel miatt ide nem kerülhet a vezérlés.
    DBMS_OUTPUT.PUT_LINE('Mégiscak elfért az a sztring a változóban.');
    DBMS_OUTPUT.PUT_LINE(s);

  EXCEPTION
    WHEN VALUE_ERROR THEN
      DBMS_OUTPUT.PUT_LINE('VALUE_ERROR volt.');
      DBMS_OUTPUT.PUT_LINE(s); -- 'Almafa'
  END;

  -- A RETURN utasítás hatására is befejezõdik a blokk mûködése.
  -- Ilyenkor az összes tartalmazó blokk mûködése is befejezõdik!
  BEGIN
    RETURN; -- A kulso címkéjû blokk mûködése is befejezõdik.
    
    -- Ide soha nem kerülhet a vezérlés.
    DBMS_OUTPUT.PUT_LINE('Sikertelen RETURN 1. ?!');
  END;

  -- És ide sem kerülhet a vezérlés.
  DBMS_OUTPUT.PUT_LINE('Sikertelen RETURN 2. ?!');

END;
/

/*
Eredmény:

SQL> @prog_1_blokk
hal
Elhallgató fejhallgató
VALUE_ERROR volt.
Almafa

A PL/SQL eljárás sikeresen befejezõdött.

*/
