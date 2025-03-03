DECLARE

  TYPE t_egyed IS RECORD (
    id         NUMBER,
    leiras     VARCHAR2(100)
  );

  /* erõs típusú REF CURSOR */
  TYPE t_ref_egyed IS REF CURSOR RETURN t_egyed;
  /* gyenge típusú REF CURSOR típust nem kell deklarálnunk,
     a SYS_REFCURSOR típust használjuk helyette */

  /* Kurzorváltozók */
  v_Refcursor      SYS_REFCURSOR;
  v_Egyedek1       t_ref_egyed;
  v_Egyedek2       t_ref_egyed;

  v_Egyed          t_egyed;

  /* Megnyit egy gyengén típusos kurzort. */
  PROCEDURE megnyit_konyv(p_cursor IN OUT SYS_REFCURSOR) IS
  BEGIN
    OPEN p_cursor FOR
      SELECT id, cim FROM konyv;
  END;
  
  /* Megnyit egy erõsen típusos kurzort. */
  FUNCTION megnyit_ugyfel RETURN t_ref_egyed IS
    rv       t_ref_egyed;
  BEGIN
    OPEN rv FOR 
      SELECT id, nev FROM ugyfel;
    RETURN rv;
  END;
  
  /* Egy sort betölt a kurzorból és visszadja.
     A visszatérési érték másolása miatt nem
     célszerû használni. */
  FUNCTION betolt(p_cursor IN t_ref_egyed) 
  RETURN t_egyed IS
    rv       t_egyed;
  BEGIN
    FETCH p_cursor INTO rv;
    RETURN rv;
  END;

  /* Bezár egy tetszõleges kurzort. */
  PROCEDURE bezar(p_cursor IN SYS_REFCURSOR) IS
  BEGIN
    IF p_cursor%ISOPEN THEN 
      CLOSE p_cursor;
    END IF;
  END;

BEGIN
  /* Elemezze a típuskompatibilitási problémákat ! */

  megnyit_konyv(v_Egyedek1);
  v_Refcursor := megnyit_ugyfel;
  /* Innentõl kezdve a v_Refcursor és a v_Egyedek2 ugyanazt
     a kurzort jelenti! */
  v_Egyedek2 := v_Refcursor;
  v_Egyed := betolt(v_Egyedek2);
  DBMS_OUTPUT.PUT_LINE(v_Egyed.id || ', ' || v_Egyed.leiras);
  v_Egyed := betolt(v_Refcursor);
  DBMS_OUTPUT.PUT_LINE(v_Egyed.id || ', ' || v_Egyed.leiras);

  /* Most pedig v_Refcursor és a v_Egyedek1 egyezik meg. */
  v_Refcursor := v_Egyedek1;
  v_Egyed := betolt(v_Egyedek1);
  DBMS_OUTPUT.PUT_LINE(v_Egyed.id || ', ' || v_Egyed.leiras);
  v_Egyed := betolt(v_Refcursor);
  DBMS_OUTPUT.PUT_LINE(v_Egyed.id || ', ' || v_Egyed.leiras);

  bezar(v_Egyedek1);
  bezar(v_Egyedek2);

  BEGIN
    /* Ezt a kurzort már bezártuk egyszer v_Egyedek1 néven! */
    v_Egyed := betolt(v_Refcursor);
    DBMS_OUTPUT.PUT_LINE(v_Egyed.id || ', ' || v_Egyed.leiras);
  EXCEPTION
    WHEN INVALID_CURSOR THEN
      DBMS_OUTPUT.PUT_LINE('Tényleg be volt zárva!');
  END;

  /* Itt nem szereplhetne sem v_Egyedek1, sem v_Egyedek2. */
  OPEN v_Refcursor FOR
    SELECT 'alma',2,3,4 FROM DUAL;

  /* Ez az értékadás most kompatibilitási problémát eredményez! 
     Az elõbb nem okozott hibát, mert az ellenõrzés futási
     idõben történik. */
  v_Egyedek2 := v_Refcursor;

EXCEPTION
  WHEN OTHERS THEN
    CLOSE v_Refcursor;
    RAISE;
END;
/

/*
Eredmény:

5, Kovács János
10, Szabó Máté István
5, A római jog története és institúciói
10, A teljesség felé
Tényleg be volt zárva!
DECLARE
*
Hiba a(z) 1. sorban:
ORA-06504: PL/SQL: Az Eredményhalmaz-változók vagy a kérdés visszaadott típusai nem illeszkednek
ORA-06512: a(z) helyen a(z) 99. sornál

*/
