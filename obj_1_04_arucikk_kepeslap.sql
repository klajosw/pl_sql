CREATE TYPE T_Arucikk IS OBJECT (
  leiras     VARCHAR2(200),
  ar         NUMBER,
  mennyiseg  NUMBER,
  MEMBER PROCEDURE felvesz(p_mennyiseg NUMBER),
  MEMBER PROCEDURE elad(p_Mennyiseg NUMBER, p_Teljes_ar OUT NUMBER),
  MAP MEMBER FUNCTION osszertek RETURN NUMBER
) NOT FINAL NOT INSTANTIABLE
/

CREATE OR REPLACE TYPE BODY T_Arucikk AS

  MEMBER PROCEDURE felvesz(p_Mennyiseg NUMBER) IS
  -- Raktárra veszi a megadott mennyiségû árucikket
  BEGIN
    mennyiseg := mennyiseg + p_Mennyiseg;
  END felvesz;

  MEMBER PROCEDURE elad(p_Mennyiseg NUMBER, p_Teljes_ar OUT NUMBER) IS
  /* Csökkenti az árucikkbõl a készletet a megadott mennyiséggel
     Ha nincs elég árucikk, akkor kivételt vált ki.
     A p_Teljes_ar megadja az eladott cikkek (esetlegesen
     kedvezményes) fizetendõ árát. */
  BEGIN
    IF mennyiseg < p_Mennyiseg THEN
      RAISE_APPLICATION_ERROR(-20101, 'Nincs elég árucikk');
    END IF;

    p_Teljes_ar := p_Mennyiseg * ar;
    mennyiseg := mennyiseg - p_Mennyiseg;
  END elad;

  MAP MEMBER FUNCTION osszertek RETURN NUMBER IS
  BEGIN
    RETURN ar * mennyiseg;
  END osszertek;  

END;
/
show errors

CREATE OR REPLACE TYPE T_Kepeslap UNDER T_Arucikk (
  meret    T_Teglalap
) NOT FINAL
/
show errors

CREATE OR REPLACE TYPE T_Toll UNDER T_Arucikk (
  szin          VARCHAR2(20),
  gyujto        INTEGER, -- ennyi darab együtt kedvezményes
  kedvezmeny    REAL,    -- a kedvezmény mértéke, szorzó
  OVERRIDING MEMBER PROCEDURE elad(p_Mennyiseg NUMBER, 
                                   p_Teljes_ar OUT NUMBER),
  OVERRIDING MAP MEMBER FUNCTION osszertek RETURN NUMBER
) NOT FINAL
/
show errors


CREATE OR REPLACE TYPE BODY T_Toll AS
  OVERRIDING MEMBER PROCEDURE elad(p_Mennyiseg NUMBER, 
                                   p_Teljes_ar OUT NUMBER) IS
  BEGIN
    IF mennyiseg < p_Mennyiseg THEN
      RAISE_APPLICATION_ERROR(-20101, 'Nincs elég árucikk');
    END IF;

    mennyiseg := mennyiseg - p_Mennyiseg;
    p_Teljes_ar := p_Mennyiseg * ar;
    IF p_Mennyiseg >= gyujto THEN
      p_Teljes_ar := p_Teljes_ar * kedvezmeny;
    END IF;
  END elad;

  OVERRIDING MAP MEMBER FUNCTION osszertek RETURN NUMBER IS
    v_Osszertek   NUMBER;
  BEGIN
    v_Osszertek := mennyiseg * ar;
    IF mennyiseg >= gyujto THEN
      v_Osszertek := v_Osszertek * kedvezmeny;
    END IF;
  END osszertek;

END;
/ 
show errors

CREATE OR REPLACE TYPE T_Sorkihuzo UNDER T_Toll (
  vastagsag     NUMBER
)
/

/* Egy apró példa */
DECLARE
  v_Toll  T_Toll;
  v_Ar    NUMBER;
BEGIN
  v_Toll := NEW T_Toll('Golyóstoll', 150, 55, 'kék', 8, 0.95);
  v_Toll.elad(24, v_Ar);
  DBMS_OUTPUT.PUT_LINE('megmaradt mennyiség: ' || v_Toll.mennyiseg
    || ', eladási ár: ' || v_Ar);
END;
/
/* 
Eredmény:

megmaradt mennyiség: 31, eladási ár: 3420

A PL/SQL eljárás sikeresen befejezõdött.
*/
