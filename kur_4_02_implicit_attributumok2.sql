DECLARE

  v_Temp       NUMBER;

  /* Eljárás, ami implicit kurzort használ. */
  PROCEDURE alprg IS
    i          NUMBER;
  BEGIN
    SELECT 1 INTO i FROM DUAL;
  END;

BEGIN
  /* Ez a DELETE nem töröl egy sort sem. */
  DELETE FROM konyv
    WHERE 1 = 2;
  /* Nem biztonságos használat! Az alprogramhívás megváltoztathatja az
     implicit attribútumok értékét, mert azok mindig a legutolsó
     SQL-utasításra vonatkoznak. */
  alprg;
  DBMS_OUTPUT.PUT_LINE('SQL%ROWCOUNT: ' || SQL%ROWCOUNT);

  /* Ez a DELETE nem töröl egy sort sem. */
  DELETE FROM konyv
    WHERE 1 = 2;
  /* Az a biztonságos, ha a szükséges attribútumok értékét
     ideiglenesen tároljuk. */
  v_Temp := SQL%ROWCOUNT;
  alprg;
  DBMS_OUTPUT.PUT_LINE('SQL%ROWCOUNT: ' || v_Temp);

END;
/

/*
Eredmény:

SQL%ROWCOUNT: 1
SQL%ROWCOUNT: 0

A PL/SQL eljárás sikeresen befejezõdött.

*/
