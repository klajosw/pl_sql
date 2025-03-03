/*
  CAST csak SQL-ben van. A típusnak adatbázistípusnak 
  kell lennie, viszont skalár is lehet.
*/
CREATE TYPE T_Rec IS OBJECT (
  szam   NUMBER,
  nev    VARCHAR2(100)
)
/

CREATE TYPE T_Dinamikus IS VARRAY(10) OF T_Rec
/

CREATE TYPE T_Beagyazott IS TABLE OF T_Rec
/

DECLARE
  v_Dinamikus   T_Dinamikus;
  v_Beagyazott  T_Beagyazott;

BEGIN
  SELECT CAST(v_Beagyazott AS T_Dinamikus) 
    INTO v_Dinamikus
    FROM dual;
  
  SELECT CAST(MULTISET(SELECT id, cim FROM konyv ORDER BY UPPER(cim))
              AS T_Beagyazott)
    INTO v_Beagyazott
    FROM dual;
END;
/

DROP TYPE T_Beagyazott;
DROP TYPE T_Dinamikus;
DROP TYPE T_Rec;
