/* Exit 2 - A címke segítségével nem csak a belsõ ciklus fejezhetõ be. */
DECLARE
  v_Osszeg PLS_INTEGER := 0;
BEGIN

  <<kulso>>
  FOR i IN 1..100 LOOP
    FOR j IN 1..i LOOP
      v_Osszeg := v_Osszeg + i;
      -- Ha elértük a keresett összeget, mindkét ciklusból kilépünk.
      EXIT kulso WHEN v_Osszeg > 100;
    END LOOP;
  END LOOP;

  DBMS_OUTPUT.PUT_LINE(v_Osszeg);
END;
/
