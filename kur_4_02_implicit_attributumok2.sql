DECLARE

  v_Temp       NUMBER;

  /* Elj�r�s, ami implicit kurzort haszn�l. */
  PROCEDURE alprg IS
    i          NUMBER;
  BEGIN
    SELECT 1 INTO i FROM DUAL;
  END;

BEGIN
  /* Ez a DELETE nem t�r�l egy sort sem. */
  DELETE FROM konyv
    WHERE 1 = 2;
  /* Nem biztons�gos haszn�lat! Az alprogramh�v�s megv�ltoztathatja az
     implicit attrib�tumok �rt�k�t, mert azok mindig a legutols�
     SQL-utas�t�sra vonatkoznak. */
  alprg;
  DBMS_OUTPUT.PUT_LINE('SQL%ROWCOUNT: ' || SQL%ROWCOUNT);

  /* Ez a DELETE nem t�r�l egy sort sem. */
  DELETE FROM konyv
    WHERE 1 = 2;
  /* Az a biztons�gos, ha a sz�ks�ges attrib�tumok �rt�k�t
     ideiglenesen t�roljuk. */
  v_Temp := SQL%ROWCOUNT;
  alprg;
  DBMS_OUTPUT.PUT_LINE('SQL%ROWCOUNT: ' || v_Temp);

END;
/

/*
Eredm�ny:

SQL%ROWCOUNT: 1
SQL%ROWCOUNT: 0

A PL/SQL elj�r�s sikeresen befejez�d�tt.

*/
