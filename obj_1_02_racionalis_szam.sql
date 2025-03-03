CREATE OR REPLACE TYPE T_Racionalis_szam AS OBJECT ( 
  szamlalo INTEGER,
  nevezo   INTEGER,

  STATIC FUNCTION lnko(x INTEGER, y INTEGER) RETURN INTEGER,

  -- Megj: van alapértelmezett konstruktor is.
  CONSTRUCTOR FUNCTION T_Racionalis_szam(p_Egesz INTEGER) 
    RETURN SELF AS RESULT,
  CONSTRUCTOR FUNCTION T_Racionalis_szam(p_Tort VARCHAR2) 
    RETURN SELF AS RESULT,
  MAP MEMBER FUNCTION konvertal RETURN REAL,
  MEMBER PROCEDURE egyszerusit,
  MEMBER FUNCTION reciprok RETURN T_Racionalis_szam,
  MEMBER FUNCTION to_char RETURN VARCHAR2,
  MEMBER FUNCTION plusz(x T_Racionalis_szam) RETURN T_Racionalis_szam,
  MEMBER FUNCTION minusz(x T_Racionalis_szam) RETURN T_Racionalis_szam,
  MEMBER FUNCTION szorozva(x T_Racionalis_szam) RETURN T_Racionalis_szam,
  MEMBER FUNCTION osztva(x T_Racionalis_szam) RETURN T_Racionalis_szam,
  PRAGMA RESTRICT_REFERENCES (DEFAULT, RNDS,WNDS,RNPS,WNPS)
);
/
show errors

CREATE OR REPLACE TYPE BODY T_Racionalis_szam AS 

  STATIC FUNCTION lnko(x INTEGER, y INTEGER) RETURN INTEGER IS
  -- Megadja x és y legnagyobb közös osztóját, y elõjelével.
    rv INTEGER;
  BEGIN
    IF (y < 0) OR (x < 0) THEN
      rv := lnko(ABS(x), ABS(y)) * SIGN(y);
    ELSIF (y <= x) AND (x MOD y = 0) THEN
      rv := y;
    ELSIF x < y THEN 
      rv := lnko(y, x);  -- rekurzív hívás
    ELSE
      rv := lnko(y, x MOD y);  -- rekurzív hívás
    END IF;
    RETURN rv;
  END;

  CONSTRUCTOR FUNCTION T_Racionalis_szam(p_Egesz INTEGER) 
    RETURN SELF AS RESULT
  IS
  BEGIN
    SELF := NEW T_Racionalis_szam(p_Egesz, 1);
    RETURN;
  END;

  CONSTRUCTOR FUNCTION T_Racionalis_szam(p_Tort VARCHAR2) 
    RETURN SELF AS RESULT
  IS
    v_Perjel_poz PLS_INTEGER;
  BEGIN
    v_Perjel_poz := INSTR(p_Tort, '/');
    SELF := NEW T_Racionalis_szam(
              TO_NUMBER(SUBSTR(p_Tort,1,v_Perjel_poz-1)), 
              TO_NUMBER(SUBSTR(p_Tort,v_Perjel_poz+1))
    );
    RETURN;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE VALUE_ERROR;
  END;

  MAP MEMBER FUNCTION konvertal RETURN REAL IS
   -- Valós számmá konvertálja a számpárral reprezentált racionális számot.
  BEGIN
    RETURN szamlalo / nevezo;
  END konvertal;

  MEMBER PROCEDURE egyszerusit IS
   -- Egyszerûsíti a legegyszerübb alakra.
    l INTEGER;
  BEGIN
    l := T_Racionalis_szam.lnko(szamlalo, nevezo);
    szamlalo := szamlalo / l;
    nevezo   := nevezo / l;
  END egyszerusit;

  MEMBER FUNCTION reciprok RETURN T_Racionalis_szam IS
  -- Megadja a reciprokot.
  BEGIN
    RETURN T_Racionalis_szam(nevezo, szamlalo);  -- konstruktorhívás
  END reciprok;

  MEMBER FUNCTION to_char RETURN VARCHAR2 IS
  BEGIN
    RETURN szamlalo || '/' || nevezo;
  END to_char;

  MEMBER FUNCTION plusz(x T_Racionalis_szam) RETURN T_Racionalis_szam IS
  -- Megadja a SELF + x összeget.
    rv T_Racionalis_szam;
  BEGIN
    rv := T_Racionalis_szam(szamlalo * x.nevezo + x.szamlalo * nevezo, nevezo * x.nevezo);
    rv.egyszerusit;
    RETURN rv;
  END plusz;

  MEMBER FUNCTION minusz(x T_Racionalis_szam) RETURN T_Racionalis_szam IS
  -- Megadja a SELF - x értékét.
    rv T_Racionalis_szam;
  BEGIN
    rv := T_Racionalis_szam(szamlalo * x.nevezo - x.szamlalo * nevezo, nevezo * x.nevezo);
    rv.egyszerusit;
    RETURN rv;
  END minusz;

  MEMBER FUNCTION szorozva(x T_Racionalis_szam) RETURN T_Racionalis_szam IS
  -- Megadja a SELF * x értékét.
    rv T_Racionalis_szam;
  BEGIN
    rv := T_Racionalis_szam(szamlalo * x.szamlalo, nevezo * x.nevezo);
    rv.egyszerusit;
    RETURN rv;
  END szorozva;

  MEMBER FUNCTION osztva(x T_Racionalis_szam) RETURN T_Racionalis_szam IS
  -- Megadja a SELF / x értékét.
    rv T_Racionalis_szam;
  BEGIN
    rv := T_Racionalis_szam(szamlalo * x.nevezo, nevezo * x.szamlalo);
    rv.egyszerusit;
    RETURN rv;
  END osztva;
END;
/
show errors

/* Egy apró példa: */
DECLARE
  x T_Racionalis_szam;
  y T_Racionalis_szam;
  z T_Racionalis_szam;
BEGIN
  x := NEW T_Racionalis_szam(80, -4);
  x.egyszerusit;
  y := NEW T_Racionalis_szam(-4, -3);
  y.egyszerusit;
  z := x.plusz(y);
  DBMS_OUTPUT.PUT_LINE(x.to_char || ' + ' || y.to_char
    || ' = ' || z.to_char);

  -- Alternatív konstrukotrok használata
  x := NEW T_Racionalis_szam(10);
  y := NEW T_Racionalis_szam('23 / 12');
  /*
  Hibás konstruktorhívások:
  z := NEW T_Racionalis_szam('a/b');
  z := NEW T_Racionalis_szam('1.2 / 3.12');
  */
END;
/
/*
Eredmény:

-20/1 + 4/3 = -56/3

A PL/SQL eljárás sikeresen befejezõdött.
*/
