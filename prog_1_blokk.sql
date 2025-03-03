/* Blokk */
<<kulso>>
DECLARE
  s     VARCHAR2(30) := 'hal';
BEGIN

  /* be�gyazott blokk */
  DECLARE
    s2  VARCHAR2(20) := 'El_lgat� fej_lgat�';
  BEGIN
    -- s2 is �s s is l�that�
    DBMS_OUTPUT.PUT_LINE(s); -- 'hal'

    s := REPLACE(s2, '_', s);
    -- blokk v�ge
  END;

  DBMS_OUTPUT.PUT_LINE(s); -- 'Elhallgat� fejhallgat�'

  /* A k�vetkez� sor ford�t�si hib�t eredm�nyezne, mert s2 m�r nem l�that�.
  DBMS_OUTPUT.PUT_LINE(s2);
  */

  <<belso>>
  DECLARE
    s   NUMBER;  -- elfedi a k�ls� blokkbeli deklar�ci�t
  BEGIN
    s := 5;
    belso.s := 7;
    kulso.s := 'Almafa';

    GOTO ki;
    
    -- Ide soha nem ker�lhet a vez�rl�s.
    DBMS_OUTPUT.PUT_LINE('Sikertelen GOTO ?!');
  END;    

  DBMS_OUTPUT.PUT_LINE(s); -- 'Almafa'

  <<ki>>
  BEGIN
    /* Ez az �rt�k nem f�r bele a v�ltoz�ba.
       VALUE_ERROR kiv�tel v�lt�dik ki. */
    s := '1234567890ABCDEFGHIJ1234567890ABCDEFGHHIJ';

    -- A kiv�tel miatt ide nem ker�lhet a vez�rl�s.
    DBMS_OUTPUT.PUT_LINE('M�giscak elf�rt az a sztring a v�ltoz�ban.');
    DBMS_OUTPUT.PUT_LINE(s);

  EXCEPTION
    WHEN VALUE_ERROR THEN
      DBMS_OUTPUT.PUT_LINE('VALUE_ERROR volt.');
      DBMS_OUTPUT.PUT_LINE(s); -- 'Almafa'
  END;

  -- A RETURN utas�t�s hat�s�ra is befejez�dik a blokk m�k�d�se.
  -- Ilyenkor az �sszes tartalmaz� blokk m�k�d�se is befejez�dik!
  BEGIN
    RETURN; -- A kulso c�mk�j� blokk m�k�d�se is befejez�dik.
    
    -- Ide soha nem ker�lhet a vez�rl�s.
    DBMS_OUTPUT.PUT_LINE('Sikertelen RETURN 1. ?!');
  END;

  -- �s ide sem ker�lhet a vez�rl�s.
  DBMS_OUTPUT.PUT_LINE('Sikertelen RETURN 2. ?!');

END;
/

/*
Eredm�ny:

SQL> @prog_1_blokk
hal
Elhallgat� fejhallgat�
VALUE_ERROR volt.
Almafa

A PL/SQL elj�r�s sikeresen befejez�d�tt.

*/
