DECLARE
  v_Datum       DATE;

  /* Visszaadja p_Datumot a p_Format form�tumban, 
    ha hi�nyzik valamelyik, akkor az alap�rtelmezett 
    kezd��rt�kkel dolgozik a f�ggv�ny */
  FUNCTION to_char2(
    p_Datum   DATE DEFAULT SYSDATE,
    p_Format  VARCHAR2 DEFAULT 'YYYY-MON-DD HH24:MI:SS'
  ) RETURN VARCHAR2 IS
  BEGIN
    return TO_CHAR(p_Datum, p_Format);
  END to_char2; 

BEGIN
  v_Datum := TO_DATE('2006-�PR.  -10 20:00:00', 'YYYY-MON-DD HH24:MI:SS');
  /* sorrendi k�t�s */
  DBMS_OUTPUT.PUT_LINE('1: ' || to_char2(v_Datum, 'YYYY-MON-DD'));
  /* n�v szerinti k�t�s */
  DBMS_OUTPUT.PUT_LINE('2: ' || to_char2(p_Format => 'YYYY-MON-DD',
                                         p_Datum => v_Datum));
  /* n�v szerinti k�t�s �s param�ter hi�nya */
  DBMS_OUTPUT.PUT_LINE('3: ' || to_char2(p_Format => 'YYYY-MON-DD'));
  /* mindk�t k�t�s keverve */
  DBMS_OUTPUT.PUT_LINE('4: ' || to_char2(v_Datum,
                                         p_Format => 'YYYY-MON-DD'));
  /* mindk�t param�ter hi�nya */
  DBMS_OUTPUT.PUT_LINE('5: ' || to_char2);
END;
/

/*
Eredm�ny (az aktu�lis d�tum ma 2006-J�N.  -19):

1: 2006-�PR.  -10
2: 2006-�PR.  -10
3: 2006-J�N.  -19
4: 2006-�PR.  -10
5: 2006-J�N.  -19 17:39:16

A PL/SQL elj�r�s sikeresen befejez�d�tt.
*/  
