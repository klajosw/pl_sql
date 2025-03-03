SELECT DEREF(ugyfel_ref) AS ugyfel, DEREF(kezes_ref) AS kezes
  FROM hitelek;

DELETE FROM hitelek 
  WHERE DEREF(ugyfel_ref) IS NULL; 
