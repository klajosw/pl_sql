DECLARE
  v_Datum       DATE;

  /* Visszaadja p_Datumot a p_Format formátumban, 
    ha hiányzik valamelyik, akkor az alapértelmezett 
    kezdõértékkel dolgozik a függvény */
  FUNCTION to_char2(
    p_Datum   DATE DEFAULT SYSDATE,
    p_Format  VARCHAR2 DEFAULT 'YYYY-MON-DD HH24:MI:SS'
  ) RETURN VARCHAR2 IS
  BEGIN
    return TO_CHAR(p_Datum, p_Format);
  END to_char2; 

BEGIN
  v_Datum := TO_DATE('2006-ÁPR.  -10 20:00:00', 'YYYY-MON-DD HH24:MI:SS');
  /* sorrendi kötés */
  DBMS_OUTPUT.PUT_LINE('1: ' || to_char2(v_Datum, 'YYYY-MON-DD'));
  /* név szerinti kötés */
  DBMS_OUTPUT.PUT_LINE('2: ' || to_char2(p_Format => 'YYYY-MON-DD',
                                         p_Datum => v_Datum));
  /* név szerinti kötés és paraméter hiánya */
  DBMS_OUTPUT.PUT_LINE('3: ' || to_char2(p_Format => 'YYYY-MON-DD'));
  /* mindkét kötés keverve */
  DBMS_OUTPUT.PUT_LINE('4: ' || to_char2(v_Datum,
                                         p_Format => 'YYYY-MON-DD'));
  /* mindkét paraméter hiánya */
  DBMS_OUTPUT.PUT_LINE('5: ' || to_char2);
END;
/

/*
Eredmény (az aktuális dátum ma 2006-JÚN.  -19):

1: 2006-ÁPR.  -10
2: 2006-ÁPR.  -10
3: 2006-JÚN.  -19
4: 2006-ÁPR.  -10
5: 2006-JÚN.  -19 17:39:16

A PL/SQL eljárás sikeresen befejezõdött.
*/  
