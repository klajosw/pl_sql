CREATE TYPE T_Szemely AS OBJECT(
  nev     VARCHAR2(35),
  telefon VARCHAR2(12)
)
/

CREATE TABLE szemelyek OF T_Szemely;
