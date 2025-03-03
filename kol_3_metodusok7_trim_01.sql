DECLARE
  v_Szerzok     T_Szerzok;
BEGIN
  v_Szerzok := T_Szerzok('M�ricz Zsigmond', 'M�ra Ferenc',
     'Ottlik G�za', 'We�res S�ndor');

  DBMS_OUTPUT.PUT_LINE('1. count: ' || v_Szerzok.COUNT);

  -- T�rl�nk egy elemet
  v_Szerzok.TRIM;
  DBMS_OUTPUT.PUT_LINE('2. count: ' || v_Szerzok.COUNT);

  -- T�rl�nk 2 elemet
  v_Szerzok.TRIM(2);
  DBMS_OUTPUT.PUT_LINE('3. count: ' || v_Szerzok.COUNT);

  BEGIN
    -- Megpr�b�lunk t�l sok elemet t�r�lni
    v_Szerzok.TRIM(10);
  EXCEPTION
    WHEN SUBSCRIPT_BEYOND_COUNT THEN
      DBMS_OUTPUT.PUT_LINE('Kiv�tel! ' || SQLERRM);
  END;

  DBMS_OUTPUT.PUT_LINE('4. count: ' || v_Szerzok.COUNT);

END;
/

/*
Eredm�ny:

1. count: 4
2. count: 3
3. count: 1
Kiv�tel! ORA-06533: Sz�ml�l�n k�v�li index �rt�k
4. count: 1

A PL/SQL elj�r�s sikeresen befejez�d�tt.
*/
