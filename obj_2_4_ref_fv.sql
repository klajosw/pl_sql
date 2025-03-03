INSERT INTO hitelek 
  SELECT '767-8967-6' AS azonosito, 65000 AS osszeg, 
         SYSDATE+365 AS lejarat,
         REF(u) AS ugyfel_ref, REF(sz) AS kezes_ref
    FROM hitel_ugyfelek u, szemelyek sz
    WHERE u.nev = 'Nagy István'
      AND sz.nev = 'Kiss Aranka'
;

SELECT * FROM hitelek;

DELETE FROM hitel_ugyfelek WHERE nev = 'Nagy István';

SELECT * FROM hitelek WHERE ugyfel_ref IS DANGLING;
