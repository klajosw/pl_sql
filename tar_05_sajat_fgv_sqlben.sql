CREATE OR REPLACE FUNCTION hatralevo_napok(
  p_Kolcsonzo   kolcsonzes.kolcsonzo%TYPE, 
  p_Konyv       kolcsonzes.konyv%TYPE
) RETURN INTEGER
AS
/* Megadja egy k�lcs�nz�tt k�nyv h�tralev� k�lcs�nz�si idej�t. */
  v_Datum          kolcsonzes.datum%TYPE;
  v_Most           DATE;
  v_Hosszabbitva   kolcsonzes.hosszabbitva%TYPE;  

BEGIN
  SELECT datum, hosszabbitva
    INTO v_Datum, v_Hosszabbitva
    FROM kolcsonzes
    WHERE kolcsonzo = p_Kolcsonzo
      AND konyv = p_Konyv;

  /* Lev�gjuk a d�tumokb�l az �ra r�szt. */
  v_Datum := TRUNC(v_Datum, 'DD');
  v_Most  := TRUNC(SYSDATE, 'DD');

  /* Visszaadjuk a k�l�nbs�get. */
  RETURN (v_Hosszabbitva + 1) * 30 + v_Datum - v_Most;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN NULL;
END hatralevo_napok;
/
show errors

SELECT ugyfel, konyv, hatralevo_napok(ugyfel_id, konyv_id) AS hatra
  FROM ugyfel_konyv
  WHERE ugyfel_id = 10 -- Szab� M�t� Istv�n
/

/* 
Eredm�ny: (A p�lda futtat�sakor a d�tum: 2002. m�jus 9.)

UGYFEL
--------------------------------------------------------------
KONYV                                                               HATRA
-------------------------------------------------------------- ----------
Szab� M�t� Istv�n
Matematikai K�zik�nyv                                                  12

Szab� M�t� Istv�n
Matematikai zseblexikon                                                12

Szab� M�t� Istv�n
SQL:1999 Understanding Relational Language Components                  12


Megjegyz�s: 
~~~~~~~~~~~
Adatb�zisp�ld�ny szinten lehet�s�g van a SYSDATE �rt�k�t
r�gz�teni a FIXED_DATE inicializ�ci�s param�terrel
(ehhez ALTER SYSYTEM jogosults�g sz�ks�ges):

ALTER SYSTEM SET FIXED_DATE='2002-M�J.  -09' SCOPE=MEMORY;
ALTER SYSTEM SET FIXED_DATE=NONE SCOPE=MEMORY;
*/
