/* Exit 1 - Az EXIT hatására a ciklus befejezõdik. */
DECLARE
  v_Osszeg PLS_INTEGER;
  i        PLS_INTEGER;
BEGIN
  i := 1;
  v_Osszeg := 0;

  LOOP
    v_Osszeg := v_Osszeg + i;
    IF v_Osszeg >= 100 THEN
      EXIT; -- elértük a célt
    END IF;
    i := i+1;
  END LOOP;

  DBMS_OUTPUT.PUT_LINE(i
      || ' az elsõ olyan n szám, melyre 1 + 2 + ... + n >= 100.');
END;
/
