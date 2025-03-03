DECLARE
  v_Szerzok     T_Szerzok := T_Szerzok();
BEGIN
  
  DBMS_OUTPUT.PUT_LINE('1. count: ' || v_Szerzok.COUNT
    || ' Limit: ' || NVL(TO_CHAR(v_Szerzok.LIMIT), 'NULL'));

  -- Egy NULL elemmel b�v�t�nk

  v_Szerzok.EXTEND;

  DBMS_OUTPUT.PUT_LINE('2. count: ' || v_Szerzok.COUNT
    || ' v_Szerzok(1): ' || NVL(v_Szerzok(1), 'NULL'));

  v_Szerzok(1) := 'M�ra Ferenc';

  DBMS_OUTPUT.PUT_LINE('2. count: ' || v_Szerzok.COUNT
    || ' v_Szerzok(v_Szerzok.COUNT): '
    || NVL(v_Szerzok(v_Szerzok.COUNT), 'NULL'));

  -- 3 NULL elemmel b�v�t�nk
  v_Szerzok.EXTEND(3);

  DBMS_OUTPUT.PUT_LINE('2. count: ' || v_Szerzok.COUNT
    || ' v_Szerzok(v_Szerzok.COUNT): '
    || NVL(v_Szerzok(v_Szerzok.COUNT), 'NULL'));

  -- 4 elemmel b�v�t�nk, ezek �rt�ke az 1. elem �rt�k�t veszik fel.
  v_Szerzok.EXTEND(4, 1);

  DBMS_OUTPUT.PUT_LINE('2. count: ' || v_Szerzok.COUNT
    || ' v_Szerzok(v_Szerzok.COUNT): '
    || NVL(v_Szerzok(v_Szerzok.COUNT), 'NULL'));

  BEGIN
    -- Megpr�bljuk a dinamikus t�mb�t t�lb�v�teni
    v_Szerzok.EXTEND(10);
  EXCEPTION
    WHEN SUBSCRIPT_OUTSIDE_LIMIT THEN
      DBMS_OUTPUT.PUT_LINE('Kiv�tel! ' || SQLERRM);
  END;

  DBMS_OUTPUT.NEW_LINE;
  FOR i IN 1..v_Szerzok.COUNT LOOP
    DBMS_OUTPUT.PUT_LINE(LPAD(i,2) || ' ' 
      || NVL(v_Szerzok(i), 'NULL'));
  END LOOP;
END;
/

/*
Eredm�ny:

1. count: 0 Limit: 10
2. count: 1 v_Szerzok(1): NULL
2. count: 1 v_Szerzok(v_Szerzok.COUNT): M�ra Ferenc
2. count: 4 v_Szerzok(v_Szerzok.COUNT): NULL
2. count: 8 v_Szerzok(v_Szerzok.COUNT): M�ra Ferenc
Kiv�tel! ORA-06532: Hat�ron k�v�li index

 1 M�ra Ferenc
 2 NULL
 3 NULL
 4 NULL
 5 M�ra Ferenc
 6 M�ra Ferenc
 7 M�ra Ferenc
 8 M�ra Ferenc

A PL/SQL elj�r�s sikeresen befejez�d�tt.
*/
