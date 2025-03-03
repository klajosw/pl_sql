DECLARE

  TYPE t_egyed IS RECORD (
    id         NUMBER,
    leiras     VARCHAR2(100)
  );

  /* er�s t�pus� REF CURSOR */
  TYPE t_ref_egyed IS REF CURSOR RETURN t_egyed;
  /* gyenge t�pus� REF CURSOR t�pust nem kell deklar�lnunk,
     a SYS_REFCURSOR t�pust haszn�ljuk helyette */

  /* Kurzorv�ltoz�k */
  v_Refcursor      SYS_REFCURSOR;
  v_Egyedek1       t_ref_egyed;
  v_Egyedek2       t_ref_egyed;

  v_Egyed          t_egyed;

  /* Megnyit egy gyeng�n t�pusos kurzort. */
  PROCEDURE megnyit_konyv(p_cursor IN OUT SYS_REFCURSOR) IS
  BEGIN
    OPEN p_cursor FOR
      SELECT id, cim FROM konyv;
  END;
  
  /* Megnyit egy er�sen t�pusos kurzort. */
  FUNCTION megnyit_ugyfel RETURN t_ref_egyed IS
    rv       t_ref_egyed;
  BEGIN
    OPEN rv FOR 
      SELECT id, nev FROM ugyfel;
    RETURN rv;
  END;
  
  /* Egy sort bet�lt a kurzorb�l �s visszadja.
     A visszat�r�si �rt�k m�sol�sa miatt nem
     c�lszer� haszn�lni. */
  FUNCTION betolt(p_cursor IN t_ref_egyed) 
  RETURN t_egyed IS
    rv       t_egyed;
  BEGIN
    FETCH p_cursor INTO rv;
    RETURN rv;
  END;

  /* Bez�r egy tetsz�leges kurzort. */
  PROCEDURE bezar(p_cursor IN SYS_REFCURSOR) IS
  BEGIN
    IF p_cursor%ISOPEN THEN 
      CLOSE p_cursor;
    END IF;
  END;

BEGIN
  /* Elemezze a t�puskompatibilit�si probl�m�kat ! */

  megnyit_konyv(v_Egyedek1);
  v_Refcursor := megnyit_ugyfel;
  /* Innent�l kezdve a v_Refcursor �s a v_Egyedek2 ugyanazt
     a kurzort jelenti! */
  v_Egyedek2 := v_Refcursor;
  v_Egyed := betolt(v_Egyedek2);
  DBMS_OUTPUT.PUT_LINE(v_Egyed.id || ', ' || v_Egyed.leiras);
  v_Egyed := betolt(v_Refcursor);
  DBMS_OUTPUT.PUT_LINE(v_Egyed.id || ', ' || v_Egyed.leiras);

  /* Most pedig v_Refcursor �s a v_Egyedek1 egyezik meg. */
  v_Refcursor := v_Egyedek1;
  v_Egyed := betolt(v_Egyedek1);
  DBMS_OUTPUT.PUT_LINE(v_Egyed.id || ', ' || v_Egyed.leiras);
  v_Egyed := betolt(v_Refcursor);
  DBMS_OUTPUT.PUT_LINE(v_Egyed.id || ', ' || v_Egyed.leiras);

  bezar(v_Egyedek1);
  bezar(v_Egyedek2);

  BEGIN
    /* Ezt a kurzort m�r bez�rtuk egyszer v_Egyedek1 n�ven! */
    v_Egyed := betolt(v_Refcursor);
    DBMS_OUTPUT.PUT_LINE(v_Egyed.id || ', ' || v_Egyed.leiras);
  EXCEPTION
    WHEN INVALID_CURSOR THEN
      DBMS_OUTPUT.PUT_LINE('T�nyleg be volt z�rva!');
  END;

  /* Itt nem szereplhetne sem v_Egyedek1, sem v_Egyedek2. */
  OPEN v_Refcursor FOR
    SELECT 'alma',2,3,4 FROM DUAL;

  /* Ez az �rt�kad�s most kompatibilit�si probl�m�t eredm�nyez! 
     Az el�bb nem okozott hib�t, mert az ellen�rz�s fut�si
     id�ben t�rt�nik. */
  v_Egyedek2 := v_Refcursor;

EXCEPTION
  WHEN OTHERS THEN
    CLOSE v_Refcursor;
    RAISE;
END;
/

/*
Eredm�ny:

5, Kov�cs J�nos
10, Szab� M�t� Istv�n
5, A r�mai jog t�rt�nete �s instit�ci�i
10, A teljess�g fel�
T�nyleg be volt z�rva!
DECLARE
*
Hiba a(z) 1. sorban:
ORA-06504: PL/SQL: Az Eredm�nyhalmaz-v�ltoz�k vagy a k�rd�s visszaadott t�pusai nem illeszkednek
ORA-06512: a(z) helyen a(z) 99. sorn�l

*/
