CREATE TABLE hitel_ugyfelek OF T_Szemely;

CREATE TABLE hitelek (
  azonosito        VARCHAR2(30) PRIMARY KEY,
  osszeg           NUMBER,
  lejarat          DATE,
  ugyfel_ref       REF T_Szemely SCOPE IS hitel_ugyfelek,
  kezes_ref        REF T_Szemely -- Nem feltétlen ügyfél
)
/
