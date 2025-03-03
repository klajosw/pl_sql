/*
  A kölcsönzések ügyfél-könyv párjai.
*/

CREATE VIEW ugyfel_konyv AS
  SELECT u.id AS ugyfel_id, u.nev AS Ugyfel, 
         k.id AS konyv_id, k.cim AS Konyv 
    FROM ugyfel u, konyv k
    WHERE k.id IN (SELECT konyv_id FROM TABLE(u.konyvek))
  ORDER BY UPPER(u.nev), UPPER(k.cim)
/
