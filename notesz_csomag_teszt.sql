DECLARE
  v_Datum             DATE;
  v_Szam              NUMBER;
  v_Feljegyzes        notesz.t_feljegyzes;
  v_Feljegyzes_lista  notesz.t_feljegyzes_lista;
  v_Feljegyzesek_cur  notesz.t_refcursor;
  v_Nevek             notesz.t_szemely_lista;
  v_Szamok            notesz.t_szam_lista;
BEGIN
  BEGIN
    notesz.tabla_torol;
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Nem volt még ilyen tábla.');
  END;
  notesz.tabla_letrehoz;

  v_Feljegyzes := notesz.feljegyez(SYSDATE - 1, 'Mi volt ?', SYSDATE - 0.0001);
  v_Feljegyzes := notesz.feljegyez(SYSDATE, 'Mi van ?');
  v_Feljegyzes := notesz.feljegyez(SYSDATE+0.02, 'Mi van haver?', 
                                   p_Szemely => 'HAVER');
  v_Feljegyzes := notesz.feljegyez(SYSDATE+0.05, 'Mi van haver megint?', 
                                   SYSDATE-0.05, 'HAVER');
  v_Feljegyzes := notesz.feljegyez(SYSDATE + 1, 'Mi lesz ?');
  
  DBMS_OUTPUT.NEW_LINE;
  DBMS_OUTPUT.PUT_LINE('Kurzor teszt:');
  v_Feljegyzesek_cur := notesz.feljegyzesek(p_Szemely => 'HAVER');
  LOOP
    FETCH v_Feljegyzesek_cur INTO v_Feljegyzes;
    EXIT WHEN v_Feljegyzesek_cur%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE(v_Feljegyzesek_cur%ROWCOUNT || ', ' 
      || v_Feljegyzes.szoveg);
  END LOOP;
  CLOSE v_Feljegyzesek_cur;

  DBMS_OUTPUT.NEW_LINE;
  DBMS_OUTPUT.PUT_LINE('Lista teszt:');
  notesz.feljegyzes_lista(v_Nevek, v_Szamok); 
  FOR i IN 1..v_Nevek.COUNT LOOP
    DBMS_OUTPUT.PUT_LINE(i || ', ' || v_Nevek(i) || ': ' || v_Szamok(i));
  END LOOP;

  DBMS_OUTPUT.NEW_LINE;
  DBMS_OUTPUT.PUT_LINE('Listázó teszt:');
  notesz.feljegyzesek_listaz; 

  DBMS_OUTPUT.NEW_LINE;
  DBMS_OUTPUT.PUT_LINE('Idõ növekvõ:');
  notesz.elso_feljegyzes(v_Datum);
  WHILE v_Datum IS NOT NULL LOOP
    DBMS_OUTPUT.PUT_LINE(TO_CHAR(v_Datum, 'YYYY-MON-DD HH24:MI'));
    notesz.kovetkezo_feljegyzes(v_Datum);
  END LOOP;

  DBMS_OUTPUT.NEW_LINE;
  DBMS_OUTPUT.PUT_LINE('Idõ csökkenõ:');
  notesz.utolso_feljegyzes(v_Datum);
  WHILE v_Datum IS NOT NULL LOOP
    DBMS_OUTPUT.PUT_LINE(TO_CHAR(v_Datum, 'YYYY-MON-DD HH24:MI'));
    notesz.elozo_feljegyzes(v_Datum);
  END LOOP;

  DBMS_OUTPUT.NEW_LINE;
  DBMS_OUTPUT.PUT_LINE('Lejárt teszt:');
  v_Szam := notesz.torol_lejart;
  DBMS_OUTPUT.PUT_LINE('Törölt elemek száma: ' || v_Szam);
  EXECUTE IMMEDIATE 'SELECT COUNT(1) FROM notesz_feljegyzesek'
    INTO v_Szam;
  DBMS_OUTPUT.PUT_LINE('Ennyi maradt: ' || v_Szam);
  
  DBMS_OUTPUT.NEW_LINE;
  DBMS_OUTPUT.PUT_LINE('Törlés teszt:');
  v_Nevek := notesz.t_szemely_lista('HAVER', 'Haha', 'PLSQL');
  notesz.feljegyzesek_torol(v_Nevek, v_Szamok);
  FOR i IN 1..v_Nevek.COUNT LOOP
    DBMS_OUTPUT.PUT_LINE(i || ', ' || v_Nevek(i) || ': ' || v_Szamok(i));
  END LOOP;

  EXECUTE IMMEDIATE 'SELECT COUNT(1) FROM notesz_feljegyzesek'
    INTO v_Szam;
  DBMS_OUTPUT.NEW_LINE;
  DBMS_OUTPUT.PUT_LINE('Ennyi maradt: ' || v_Szam);
  
  DBMS_OUTPUT.PUT_LINE('Vége.');
END;
/
/*
Eredmény:

Kurzor teszt:
1, Mi van haver?
2, Mi van haver megint?

Lista teszt:
1, PLSQL: 1
2, HAVER: 2

Listázó teszt:
1. 02:27, PLSQL, Mi van ?,
2. 02:56, HAVER, Mi van haver?,
3. 03:39, HAVER, Mi van haver megint?, 2006-06-23 01:15

Idõ növekvõ:
2006-JÚN.  -22 02:27
2006-JÚN.  -23 02:27
2006-JÚN.  -23 02:56
2006-JÚN.  -23 03:39
2006-JÚN.  -24 02:27

Idõ csökkenõ:
2006-JÚN.  -24 02:27
2006-JÚN.  -23 03:39
2006-JÚN.  -23 02:56
2006-JÚN.  -23 02:27
2006-JÚN.  -22 02:27

Lejárt teszt:
Törölt elemek száma: 2
Ennyi maradt: 3

Törlés teszt:
1, HAVER: 1
2, Haha: 0
3, PLSQL: 2

Ennyi maradt: 0
Vége.

A PL/SQL eljárás sikeresen befejezõdött.
*/
