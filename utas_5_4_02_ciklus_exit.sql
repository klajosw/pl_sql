/* Exit 2 - A c�mke seg�ts�g�vel nem csak a bels� ciklus fejezhet� be. */
DECLARE
  v_Osszeg PLS_INTEGER := 0;
BEGIN

  <<kulso>>
  FOR i IN 1..100 LOOP
    FOR j IN 1..i LOOP
      v_Osszeg := v_Osszeg + i;
      -- Ha el�rt�k a keresett �sszeget, mindk�t ciklusb�l kil�p�nk.
      EXIT kulso WHEN v_Osszeg > 100;
    END LOOP;
  END LOOP;

  DBMS_OUTPUT.PUT_LINE(v_Osszeg);
END;
/
