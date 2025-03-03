DECLARE
  TYPE t_tablazat IS TABLE OF NUMBER
    INDEX BY VARCHAR2(10);

  v_Tablazat   t_tablazat;
  v_Kulcs      VARCHAR2(10);

BEGIN
  FOR i IN 65..67 LOOP
    v_Kulcs := CHR(i);
    v_Tablazat(v_Kulcs) := i;
  END LOOP;

  DBMS_OUTPUT.PUT_LINE('Kulcs  Elem');
  DBMS_OUTPUT.PUT_LINE('-----  ----');
  FOR i IN 0..255 LOOP
    v_Kulcs := CHR(i);
    IF v_Tablazat.EXISTS(v_Kulcs) THEN
      DBMS_OUTPUT.PUT_LINE(RPAD(v_Kulcs, 7) || v_Tablazat(v_Kulcs));
    END IF;
  END LOOP;
END;
/

/*
Eredmény:

Kulcs  Elem
-----  ----
A      65
B      66
C      67

A PL/SQL eljárás sikeresen befejezõdött.
*/
