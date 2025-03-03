/*
  Kezelj�k a k�nyvt�r �gyfeleit T_Szemely t�pus� objektumk�nt!
*/
CREATE VIEW konyvtar_ugyfelek OF T_Szemely
  WITH OBJECT IDENTIFIER(nev) AS
    SELECT SUBSTR(id || ' ' || nev, 1, 35) AS nev,
           SUBSTR(tel_szam, 1, 12)
      FROM ugyfel;

SELECT VALUE(u) FROM konyvtar_ugyfelek u;

/*
  Azonban a REF t�pusn�l megadott hitelek t�bl�ban kezesk�nt 
  nem haszn�lhatjuk az �j T_Szemely-eket.
*/
INSERT INTO hitelek 
  SELECT 'hitelazon1212' AS azonosito, 50000 AS osszeg, 
         SYSDATE + 60 AS lejarat,
         REF(u) AS ugyfel_ref, REF(k) AS kezes_ref
    FROM hitel_ugyfelek u, konyvtar_ugyfelek k
    WHERE u.nev = 'Kocsis S�ndor'
      AND k.nev like '%J�zsef Istv�n%'
;

/*
INSERT INTO hitelek
            *
Hiba a(z) 1. sorban:
ORA-22979: objektumn�zet REF vagy felhaszn�l�i REF nem sz�rhat� be (INSERT)
*/

