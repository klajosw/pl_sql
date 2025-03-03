DECLARE
  v_Datum       DATE;
  i             NUMBER := 1;  

  /* 
    Megn�veli p_Datum-ot a m�sodik p_Ido-vel, aminek
    a m�rt�kegys�g�t p_Egyseg tartalmazza. Ezek �rt�ke
    'perc', '�ra', 'nap', 'h�nap' egyike lehet.
    Ha hib�s a m�rt�kegys�g, akkor az eredeti d�tumot
    kapjuk vissza.
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
        rv := p_Datum;
    END CASE;

    RETURN rv;
  END hozzaad;

  PROCEDURE kiir(p_Datum DATE) IS
  BEGIN
    DBMS_OUTPUT.PUT_LINE(i || ': ' || TO_CHAR(p_Datum, 'YYYY-MON-DD HH24:MI:SS'));
    i := i+1;
  END kiir;     

BEGIN
  v_Datum := TO_DATE('2006-M�J.  -01 20:00:00', 'YYYY-MON-DD HH24:MI:SS');
  kiir(v_Datum);                        -- 1
  DBMS_OUTPUT.NEW_LINE;
  kiir(hozzaad(v_Datum, 5, 'perc'));    -- 2
  kiir(hozzaad(v_Datum, 1.25, '�ra'));  -- 3
  kiir(hozzaad(v_Datum, -7, 'nap'));    -- 4
  kiir(hozzaad(v_Datum, -8, 'h�nap'));  -- 5
END;
/

/*
Eredm�ny:

1: 2006-M�J.  -01 20:00:00

2: 2006-M�J.  -01 20:05:00
3: 2006-M�J.  -01 21:15:00
4: 2006-�PR.  -24 20:00:00
5: 2005-SZEPT.-01 20:00:00

A PL/SQL elj�r�s sikeresen befejez�d�tt.
*/  
