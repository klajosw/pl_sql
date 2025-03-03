CREATE OR REPLACE PROCEDURE visszahoz(
  p_Konyv       konyv.id%TYPE,
  p_Kolcsonzo   ugyfel.id%TYPE
)
AS
/* Ez az eljárás adminisztrálja egy könyv visszahozatalát.
   Azaz törli a rekordot a kölcsönzések közül (ha több egyezõ is van,
   akkor egy tetszõlegeset), valamint növeli a könyv szabad példányszámát.

   -20020-as számú felhasználói kivétel jelzi, ha nem létezik
   a kölcsönzési rekord.
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
                             'Nem létezik ilyen kölcsönzési bejegyzés');
   END IF;

   UPDATE konyv SET szabad = szabad + 1
     WHERE id = p_Konyv;

   DELETE FROM TABLE(SELECT konyvek FROM ugyfel WHERE id = p_Kolcsonzo)
     WHERE konyv_id = p_Konyv
       AND datum = v_Datum;
END visszahoz; 
/
show errors
