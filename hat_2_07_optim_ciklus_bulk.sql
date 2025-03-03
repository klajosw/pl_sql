CREATE OR REPLACE PROCEDURE proc_ciklus_bulk
IS

  TYPE t_num_tab  IS TABLE OF NUMBER;
  TYPE t_char_tab IS TABLE OF VARCHAR2(100);
  v_Num_tab       t_num_tab;
  v_Char_tab      t_char_tab;
  cur             SYS_REFCURSOR;

  -- Tesztel�st seg�t� v�ltoz�k
  t1                    NUMBER;
  t2                    NUMBER;
  lio1                  NUMBER;
  lio2                  NUMBER;
  v_Session_tag         VARCHAR2(100);

  -- Tesztel�st seg�t� elj�r�sok
  PROCEDURE cimke(p_Cimke VARCHAR2) IS
  BEGIN
    DBMS_OUTPUT.PUT(RPAD(p_Cimke, 20));
  END cimke;

  PROCEDURE tag_session
  IS
  BEGIN
    v_Session_tag := 'teszt-' || SYSTIMESTAMP;
    DBMS_APPLICATION_INFO.SET_CLIENT_INFO(v_Session_tag);
  END tag_session;

  FUNCTION get_logical_io RETURN NUMBER
  IS
    rv NUMBER;
  BEGIN
    /*
       Itt SYS tulajdon� t�bl�kat hivatkozunk.
       A lek�rdez�s�hez megfelel� jogosults�gok sz�ks�gesek.
       P�ld�ul SELECT ANY DICTIONARY rendszerjogosults�g.
    */
    SELECT st.value 
      INTO rv
      FROM v$sesstat st, v$session se, v$statname n 
     WHERE n.name = 'consistent gets'
       AND se.client_info = v_Session_tag
       AND st.sid = se.sid
       AND n.statistic# = st.statistic#
    ;
    RETURN rv;  
  END get_logical_io;

  PROCEDURE eltelt
  IS
  BEGIN
    DBMS_OUTPUT.PUT_LINE('- eltelt: ' || LPAD(t2-t1, 5)
        || ',  LIO (logical I/O) :' || LPAD((lio2-lio1), 7));
  END eltelt;

-- Az elj�r�sblokk
BEGIN
  tag_session;

  cimke('Statikus kurzor FOR');
  t1   := DBMS_UTILITY.GET_TIME;
  lio1 := get_logical_io;
  FOR i IN (
    SELECT k1.id, k1.cim 
      FROM konyv k1, konyv, konyv, konyv, konyv, konyv
     WHERE ROWNUM <= 100000
  ) 
  LOOP
    NULL;
  END LOOP;
  t2   := DBMS_UTILITY.GET_TIME;
  lio2 := get_logical_io;
  eltelt;

  cimke('Kurzor BULK FETCH');
  t1   := DBMS_UTILITY.GET_TIME;
  lio1 := get_logical_io;
  OPEN cur FOR 
    SELECT k1.id, k1.cim 
      FROM konyv k1, konyv, konyv, konyv, konyv, konyv
     WHERE ROWNUM <= 100000
  ;
  LOOP
    FETCH cur
      BULK COLLECT INTO v_Num_tab, v_Char_tab
      LIMIT 100;
    EXIT WHEN v_Num_tab.COUNT = 0; 
    FOR i IN 1..v_Num_tab.COUNT
    LOOP
      NULL;
    END LOOP;
  END LOOP;
  CLOSE cur;
  t2   := DBMS_UTILITY.GET_TIME;
  lio2 := get_logical_io;
  eltelt;

EXCEPTION
  WHEN OTHERS THEN
    IF cur%ISOPEN THEN CLOSE cur; END IF;
    RAISE;

END proc_ciklus_bulk;
/
SHOW ERRORS;

SET SERVEROUTPUT ON FORMAT WRAPPED;

-- Ford�t�s optimaliz�l�ssal, majd futtat�s

PROMPT 1. PLSQL_OPTIMIZE_LEVEL=2
ALTER PROCEDURE proc_ciklus_bulk COMPILE PLSQL_OPTIMIZE_LEVEL=2
  PLSQL_DEBUG=FALSE;
EXEC proc_ciklus_bulk;

PROMPT 2. PLSQL_OPTIMIZE_LEVEL=0
-- Ford�t�s optimaliz�l�s n�lk�l, majd futtat�s
ALTER PROCEDURE proc_ciklus_bulk COMPILE PLSQL_OPTIMIZE_LEVEL=0
  PLSQL_DEBUG=FALSE;
EXEC proc_ciklus_bulk;

/*
  Egy tipikusnak mondhat� kimenet:

...
1. PLSQL_OPTIMIZE_LEVEL=2
Az elj�r�s m�dos�tva.

Statikus kurzor FOR - eltelt:   100,  LIO (logical I/O) :  34336
Kurzor BULK FETCH   - eltelt:    81,  LIO (logical I/O) :  34336

A PL/SQL elj�r�s sikeresen befejez�d�tt.


2. PLSQL_OPTIMIZE_LEVEL=0
Az elj�r�s m�dos�tva.

Statikus kurzor FOR - eltelt:   636,  LIO (logical I/O) : 133336
Kurzor BULK FETCH   - eltelt:    80,  LIO (logical I/O) :  34336

A PL/SQL elj�r�s sikeresen befejez�d�tt.

*/
