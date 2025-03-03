DECLARE
  hibas_argumentum  EXCEPTION;
  v_Datum           DATE;

  /* 
    Megnöveli p_Datum-ot a második p_Ido-vel, aminek
    a mértékegységét p_Egyseg tartalmazza. Ezek értéke
    'perc', 'óra', 'nap', 'hónap' egyike lehet.
    Ha hibás a mértékegység, akkor hibas_argumentum kivétel 
    váltódik ki.
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
        RAISE hibas_argumentum;
    END CASE;

    RETURN rv;
  END hozzaad;

  /* Ez a függvény hibás mértékegység esetén nem vált ki
     kivételt, hanem NULL-t ad vissza. */
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
    v_Datum := hozzaad(SYSDATE, 1, 'kiskutyafüle');
  EXCEPTION
    WHEN hibas_argumentum THEN
      DBMS_OUTPUT.PUT_LINE('Blokk1 - hibás argumentum: ' 
        || SQLCODE || ', ' || SQLERRM);
  END blokk1;

  <<blokk2>>
  BEGIN
    v_Datum := hozzaad2(SYSDATE, 1, 'kiskutyafüle');
    DBMS_OUTPUT.PUT_LINE('Blokk2 - nincs kivétel.');
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Blokk2 - hiba: '
        || SQLCODE || ', ' || SQLERRM);
      RAISE; -- A hiba továbbítása külsõ irányba.
  END blokk2;

END;
/

/*
Eredmény:

Blokk1 - hibás argumentum: 1, User-Defined Exception
Blokk2 - nincs kivétel.

A PL/SQL eljárás sikeresen befejezõdött.
*/
