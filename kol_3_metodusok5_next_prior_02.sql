CREATE OR REPLACE PROCEDURE elofordulasok(p_Szoveg VARCHAR2)
IS
  c VARCHAR2(1 CHAR);

  TYPE t_gyakorisag IS TABLE OF NUMBER
    INDEX BY c%TYPE;
  v_Elofordulasok   t_gyakorisag;
BEGIN
  FOR i IN 1..LENGTH(p_Szoveg)
  LOOP
    c := LOWER(SUBSTR(p_Szoveg, i, 1));
    IF v_Elofordulasok.EXISTS(c) THEN
      v_Elofordulasok(c) := v_Elofordulasok(c)+1;
    ELSE
      v_Elofordulasok(c) := 1;
    END IF;
  END LOOP;

  -- Ford�tott sorrendhez LAST �s PRIOR kellene
  c := v_Elofordulasok.FIRST;
  WHILE c IS NOT NULL LOOP
    DBMS_OUTPUT.PUT_LINE('  ''' || c || ''' - ' 
      || v_Elofordulasok(c));
    c := v_Elofordulasok.NEXT(c);
  END LOOP;

END elofordulasok;
/
show errors;

ALTER SESSION SET NLS_COMP='ANSI';
-- Ha az NLS_LANG magyar, akkor az NLS_SORT is magyar rendez�st �r most el�
-- Egy�bk�nt kell m�g: ALTER SESSION SET NLS_SORT='Hungarian'; 

EXEC elofordulasok('Bab�m�');
/*
  'a' - 1
  '�' - 1
  'b' - 2
  '�' - 1
  'm' - 1
*/

ALTER SESSION SET NLS_COMP='BINARY';

EXEC elofordulasok('Bab�m�');
/*
  'a' - 1
  'b' - 2
  'm' - 1
  '�' - 1
  '�' - 1
*/

