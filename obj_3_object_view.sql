/*
  Kezeljük a könyvtár ügyfeleit T_Szemely típusú objektumként!
*/
CREATE VIEW konyvtar_ugyfelek OF T_Szemely
  WITH OBJECT IDENTIFIER(nev) AS
    SELECT SUBSTR(id || ' ' || nev, 1, 35) AS nev,
           SUBSTR(tel_szam, 1, 12)
      FROM ugyfel;

SELECT VALUE(u) FROM konyvtar_ugyfelek u;

/*
  Azonban a REF típusnál megadott hitelek táblában kezesként 
  nem használhatjuk az új T_Szemely-eket.
*/
INSERT INTO hitelek 
  SELECT 'hitelazon1212' AS azonosito, 50000 AS osszeg, 
         SYSDATE + 60 AS lejarat,
         REF(u) AS ugyfel_ref, REF(k) AS kezes_ref
    FROM hitel_ugyfelek u, konyvtar_ugyfelek k
    WHERE u.nev = 'Kocsis Sándor'
      AND k.nev like '%József István%'
;

/*
INSERT INTO hitelek
            *
Hiba a(z) 1. sorban:
ORA-22979: objektumnézet REF vagy felhasználói REF nem szúrható be (INSERT)
*/

