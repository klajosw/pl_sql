CREATE OR REPLACE PROCEDURE visszahoz(
  p_Konyv       konyv.id%TYPE,
  p_Kolcsonzo   ugyfel.id%TYPE
)
AS
/* Ez az elj�r�s adminisztr�lja egy k�nyv visszahozatal�t.
   Azaz t�rli a rekordot a k�lcs�nz�sek k�z�l (ha t�bb egyez� is van,
   akkor egy tetsz�legeset), valamint n�veli a k�nyv szabad p�ld�nysz�m�t.

   -20020-as sz�m� felhaszn�l�i kiv�tel jelzi, ha nem l�tezik
   a k�lcs�nz�si rekord.
*/
 
  v_Datum        kolcsonzes.datum%TYPE;

BEGIN
  DELETE FROM kolcsonzes 
    WHERE konyv = p_Konyv
      AND kolcsonzo = p_Kolcsonzo
      AND ROWNUM = 1
    RETURNING datum INTO v_Datum;

   IF SQL%ROWCOUNT = 0 THEN
     RAISE_APPLICATION_ERROR(-20020, 
                             'Nem l�tezik ilyen k�lcs�nz�si bejegyz�s');
   END IF;

   UPDATE konyv SET szabad = szabad + 1
     WHERE id = p_Konyv;

   DELETE FROM TABLE(SELECT konyvek FROM ugyfel WHERE id = p_Kolcsonzo)
     WHERE konyv_id = p_Konyv
       AND datum = v_Datum;
END visszahoz; 
/
show errors
