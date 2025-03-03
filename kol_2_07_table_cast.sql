DECLARE
  /* Kilistázzuk a kölcsönzött könyvek azonosítóját és a kölcsönzött 
     példányok számát.
  */

  v_Konyvek     T_Konyvek;
  v_Cim         konyv.cim%TYPE;

  /* Megadja egy könyv címét */
  FUNCTION a_cim(p_Konyv konyv.id%TYPE) 
    RETURN konyv.cim%TYPE
  IS
    v_Konyv     konyv.cim%TYPE;
  BEGIN
    SELECT cim INTO v_Konyv FROM konyv WHERE id = p_Konyv;
    RETURN v_Konyv;
  END a_cim;

BEGIN
  /* Lekérdezzük az összes kölcsönzést egy változóba */
  SELECT CAST(MULTISET(SELECT konyv, datum FROM kolcsonzes) AS T_Konyvek)
    INTO v_Konyvek
    FROM dual;
  
  /* Noha v_Konyvek T_Konyvek típusú, mivel változó, szükség van
     a CAST operátorra, hogy az SQL-utasításban használhassuk. */
  FOR konyv IN (
    SELECT konyv_id AS id, COUNT(1) AS peldany 
      FROM TABLE(CAST(v_Konyvek AS T_Konyvek))
      GROUP BY konyv_id
      ORDER BY peldany ASC
  ) LOOP

    DBMS_OUTPUT.PUT_LINE(LPAD(konyv.id, 3) || ' ' 
      || LPAD(konyv.peldany, 2) || ' ' || a_cim(konyv.id));
  END LOOP;
END;
/

/*
Eredmény:

  5  1 A római jog története és institúciói
 10  1 A teljesség felé
 15  1 Piszkos Fred és a többiek
 20  1 ECOOP 2001 - Object-Oriented Programming
 40  1 The Norton Anthology of American Literature - Second Edition - Volume 2
 25  1 Java - start!
 30  2 SQL:1999 Understanding Relational Language Components
 45  2 Matematikai zseblexikon
 50  2 Matematikai Kézikönyv
 35  2 A critical introduction to twentieth-century American drama - Volume 2

A PL/SQL eljárás sikeresen befejezõdött.

*/
