/* Exit 3 - EXIT WHEN - IF - GOTO */
DECLARE
  v_Osszeg PLS_INTEGER;
  i        PLS_INTEGER;
BEGIN
  i := 1;
  v_Osszeg := 0;
  LOOP
    v_Osszeg := v_Osszeg + i;

    /* A következõ 3 konstrukció ekvivalens. */
    -- 1.
    EXIT WHEN v_Osszeg >= 100;

    -- 2.
    IF v_Osszeg >= 100 THEN
      EXIT;
    END IF;

    -- 3.
    IF v_Osszeg >= 100 THEN
      GOTO ki;
    END IF;

    i := i+1;
  END LOOP;

  <<ki>>
  DBMS_OUTPUT.PUT_LINE(i
      || ' az elsõ olyan n szám, melyre 1 + 2 + ... + n >= 100.');
END;
/
