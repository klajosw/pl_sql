CREATE OR REPLACE FUNCTION hatralevo_napok(
  p_Kolcsonzo   kolcsonzes.kolcsonzo%TYPE, 
  p_Konyv       kolcsonzes.konyv%TYPE
) RETURN INTEGER
AS
/* Megadja egy kölcsönzött könyv hátralevõ kölcsönzési idejét. */
  v_Datum          kolcsonzes.datum%TYPE;
  v_Most           DATE;
  v_Hosszabbitva   kolcsonzes.hosszabbitva%TYPE;  

BEGIN
  SELECT datum, hosszabbitva
    INTO v_Datum, v_Hosszabbitva
    FROM kolcsonzes
    WHERE kolcsonzo = p_Kolcsonzo
      AND konyv = p_Konyv;

  /* Levágjuk a dátumokból az óra részt. */
  v_Datum := TRUNC(v_Datum, 'DD');
  v_Most  := TRUNC(SYSDATE, 'DD');

  /* Visszaadjuk a különbséget. */
  RETURN (v_Hosszabbitva + 1) * 30 + v_Datum - v_Most;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN NULL;
END hatralevo_napok;
/
show errors

SELECT ugyfel, konyv, hatralevo_napok(ugyfel_id, konyv_id) AS hatra
  FROM ugyfel_konyv
  WHERE ugyfel_id = 10 -- Szabó Máté István
/

/* 
Eredmény: (A példa futtatásakor a dátum: 2002. május 9.)

UGYFEL
--------------------------------------------------------------
KONYV                                                               HATRA
-------------------------------------------------------------- ----------
Szabó Máté István
Matematikai Kézikönyv                                                  12

Szabó Máté István
Matematikai zseblexikon                                                12

Szabó Máté István
SQL:1999 Understanding Relational Language Components                  12


Megjegyzés: 
~~~~~~~~~~~
Adatbázispéldány szinten lehetõség van a SYSDATE értékét
rögzíteni a FIXED_DATE inicializációs paraméterrel
(ehhez ALTER SYSYTEM jogosultság szükséges):

ALTER SYSTEM SET FIXED_DATE='2002-MÁJ.  -09' SCOPE=MEMORY;
ALTER SYSTEM SET FIXED_DATE=NONE SCOPE=MEMORY;
*/
