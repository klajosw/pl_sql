/* 
  Szinkronizáljuk a kolcsonzes táblát a 20-as azonosítójú ügyfél esetén
  az ugyfel konyvek oszlopához.
*/
DECLARE
  c_Uid         CONSTANT NUMBER := 20;  
BEGIN
  MERGE INTO kolcsonzes k
  USING (SELECT u.id, uk.konyv_id, uk.datum
           FROM ugyfel u, TABLE(u.konyvek) uk
           WHERE id = c_Uid) s
    ON (k.kolcsonzo = c_Uid AND k.konyv = s.konyv_id)
  WHEN MATCHED THEN UPDATE SET k.datum = s.datum 
  WHEN NOT MATCHED THEN INSERT (kolcsonzo, konyv, datum)
    VALUES (c_Uid, s.konyv_id, s.datum);
END;
/
