/* 
  Szinkroniz�ljuk a kolcsonzes t�bl�t a 20-as azonos�t�j� �gyf�l eset�n
  az ugyfel konyvek oszlop�hoz.
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
