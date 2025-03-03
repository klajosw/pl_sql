DECLARE
  hibas_argumentum  EXCEPTION;
  v_Datum           DATE;

  /* 
    Megn�veli p_Datum-ot a m�sodik p_Ido-vel, aminek
    a m�rt�kegys�g�t p_Egyseg tartalmazza. Ezek �rt�ke
    'perc', '�ra', 'nap', 'h�nap' egyike lehet.
    Ha hib�s a m�rt�kegys�g, akkor hibas_argumentum kiv�tel 
    v�lt�dik ki.
  */
  FUNCTION hozzaad(
    p_Datum     DATE,
    p_Ido       NUMBER,
    p_Egyseg    VARCHAR2
  ) RETURN DATE IS
    rv          DATE;
  BEGIN
    CASE p_Egyseg
      WHEN 'perc' THEN
        rv := p_Datum + p_Ido/(24*60);
      WHEN '�ra' THEN
        rv := p_Datum + p_Ido/24;
      WHEN 'nap' THEN
        rv := p_Datum + p_Ido;
      WHEN 'h�nap' THEN
        rv := ADD_MONTHS(p_Datum, p_Ido);
      ELSE
        RAISE hibas_argumentum;
    END CASE;

    RETURN rv;
  END hozzaad;

  /* Ez a f�ggv�ny hib�s m�rt�kegys�g eset�n nem v�lt ki
     kiv�telt, hanem NULL-t ad vissza. */
  FUNCTION hozzaad2(
    p_Datum     DATE,
    p_Ido       NUMBER,
    p_Egyseg    VARCHAR2
  ) RETURN DATE IS
    rv          DATE;
  BEGIN
    RETURN hozzaad(p_Datum, p_Ido, p_Egyseg);
  EXCEPTION
    WHEN hibas_argumentum THEN
      RETURN NULL;  
  END hozzaad2;

BEGIN

  <<blokk1>>
  BEGIN
    v_Datum := hozzaad(SYSDATE, 1, 'kiskutyaf�le');
  EXCEPTION
    WHEN hibas_argumentum THEN
      DBMS_OUTPUT.PUT_LINE('Blokk1 - hib�s argumentum: ' 
        || SQLCODE || ', ' || SQLERRM);
  END blokk1;

  <<blokk2>>
  BEGIN
    v_Datum := hozzaad2(SYSDATE, 1, 'kiskutyaf�le');
    DBMS_OUTPUT.PUT_LINE('Blokk2 - nincs kiv�tel.');
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Blokk2 - hiba: '
        || SQLCODE || ', ' || SQLERRM);
      RAISE; -- A hiba tov�bb�t�sa k�ls� ir�nyba.
  END blokk2;

END;
/

/*
Eredm�ny:

Blokk1 - hib�s argumentum: 1, User-Defined Exception
Blokk2 - nincs kiv�tel.

A PL/SQL elj�r�s sikeresen befejez�d�tt.
*/
