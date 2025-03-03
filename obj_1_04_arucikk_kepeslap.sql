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
  -- Rakt�rra veszi a megadott mennyis�g� �rucikket
  BEGIN
    mennyiseg := mennyiseg + p_Mennyiseg;
  END felvesz;

  MEMBER PROCEDURE elad(p_Mennyiseg NUMBER, p_Teljes_ar OUT NUMBER) IS
  /* Cs�kkenti az �rucikkb�l a k�szletet a megadott mennyis�ggel
     Ha nincs el�g �rucikk, akkor kiv�telt v�lt ki.
     A p_Teljes_ar megadja az eladott cikkek (esetlegesen
     kedvezm�nyes) fizetend� �r�t. */
  BEGIN
    IF mennyiseg < p_Mennyiseg THEN
      RAISE_APPLICATION_ERROR(-20101, 'Nincs el�g �rucikk');
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
  gyujto        INTEGER, -- ennyi darab egy�tt kedvezm�nyes
  kedvezmeny    REAL,    -- a kedvezm�ny m�rt�ke, szorz�
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
      RAISE_APPLICATION_ERROR(-20101, 'Nincs el�g �rucikk');
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

/* Egy apr� p�lda */
DECLARE
  v_Toll  T_Toll;
  v_Ar    NUMBER;
BEGIN
  v_Toll := NEW T_Toll('Goly�stoll', 150, 55, 'k�k', 8, 0.95);
  v_Toll.elad(24, v_Ar);
  DBMS_OUTPUT.PUT_LINE('megmaradt mennyis�g: ' || v_Toll.mennyiseg
    || ', elad�si �r: ' || v_Ar);
END;
/
/* 
Eredm�ny:

megmaradt mennyis�g: 31, elad�si �r: 3420

A PL/SQL elj�r�s sikeresen befejez�d�tt.
*/
