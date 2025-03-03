DECLARE
  /* Kilist�zzuk a k�lcs�nz�tt k�nyvek azonos�t�j�t �s a k�lcs�nz�tt 
     p�ld�nyok sz�m�t.
  */

  v_Konyvek     T_Konyvek;
  v_Cim         konyv.cim%TYPE;

  /* Megadja egy k�nyv c�m�t */
  FUNCTION a_cim(p_Konyv konyv.id%TYPE) 
    RETURN konyv.cim%TYPE
  IS
    v_Konyv     konyv.cim%TYPE;
  BEGIN
    SELECT cim INTO v_Konyv FROM konyv WHERE id = p_Konyv;
    RETURN v_Konyv;
  END a_cim;

BEGIN
  /* Lek�rdezz�k az �sszes k�lcs�nz�st egy v�ltoz�ba */
  SELECT CAST(MULTISET(SELECT konyv, datum FROM kolcsonzes) AS T_Konyvek)
    INTO v_Konyvek
    FROM dual;
  
  /* Noha v_Konyvek T_Konyvek t�pus�, mivel v�ltoz�, sz�ks�g van
     a CAST oper�torra, hogy az SQL-utas�t�sban haszn�lhassuk. */
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
Eredm�ny:

  5  1 A r�mai jog t�rt�nete �s instit�ci�i
 10  1 A teljess�g fel�
 15  1 Piszkos Fred �s a t�bbiek
 20  1 ECOOP 2001 - Object-Oriented Programming
 40  1 The Norton Anthology of American Literature - Second Edition - Volume 2
 25  1 Java - start!
 30  2 SQL:1999 Understanding Relational Language Components
 45  2 Matematikai zseblexikon
 50  2 Matematikai K�zik�nyv
 35  2 A critical introduction to twentieth-century American drama - Volume 2

A PL/SQL elj�r�s sikeresen befejez�d�tt.

*/
