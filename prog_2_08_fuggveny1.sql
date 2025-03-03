DECLARE
  v_Datum       DATE;
  i             NUMBER := 1;  

  /* 
    Megnöveli p_Datum-ot a második p_Ido-vel, aminek
    a mértékegységét p_Egyseg tartalmazza. Ezek értéke
    'perc', 'óra', 'nap', 'hónap' egyike lehet.
    Ha hibás a mértékegység, akkor az eredeti dátumot
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
      WHEN 'óra' THEN
        rv := p_Datum + p_Ido/24;
      WHEN 'nap' THEN
        rv := p_Datum + p_Ido;
      WHEN 'hónap' THEN
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
  v_Datum := TO_DATE('2006-MÁJ.  -01 20:00:00', 'YYYY-MON-DD HH24:MI:SS');
  kiir(v_Datum);                        -- 1
  DBMS_OUTPUT.NEW_LINE;
  kiir(hozzaad(v_Datum, 5, 'perc'));    -- 2
  kiir(hozzaad(v_Datum, 1.25, 'óra'));  -- 3
  kiir(hozzaad(v_Datum, -7, 'nap'));    -- 4
  kiir(hozzaad(v_Datum, -8, 'hónap'));  -- 5
END;
/

/*
Eredmény:

1: 2006-MÁJ.  -01 20:00:00

2: 2006-MÁJ.  -01 20:05:00
3: 2006-MÁJ.  -01 21:15:00
4: 2006-ÁPR.  -24 20:00:00
5: 2005-SZEPT.-01 20:00:00

A PL/SQL eljárás sikeresen befejezõdött.
*/  
