/* Exit 1 - Az EXIT hat�s�ra a ciklus befejez�dik. */
DECLARE
  v_Osszeg PLS_INTEGER;
  i        PLS_INTEGER;
BEGIN
  i := 1;
  v_Osszeg := 0;

  LOOP
    v_Osszeg := v_Osszeg + i;
    IF v_Osszeg >= 100 THEN
      EXIT; -- el�rt�k a c�lt
    END IF;
    i := i+1;
  END LOOP;

  DBMS_OUTPUT.PUT_LINE(i
      || ' az els� olyan n sz�m, melyre 1 + 2 + ... + n >= 100.');
END;
/
