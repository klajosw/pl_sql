DECLARE

  v_lista      T_Konyvek;

  t0           TIMESTAMP;
  t1           TIMESTAMP;
  t2           TIMESTAMP;
  t3           TIMESTAMP;
  t4           TIMESTAMP;

  PROCEDURE ido(t TIMESTAMP)
  IS
  BEGIN
    DBMS_OUTPUT.PUT_LINE(SUBSTR(TO_CHAR(t, 'SS.FF'), 1, 6));
  END ido;

  /* Az alapértelmezett átadási mód IN esetén */
  PROCEDURE inp(p T_Konyvek) IS
  BEGIN
    NULL;
  END inp;

  /* IN OUT NOCOPY nélkül */
  PROCEDURE inoutp(p IN OUT T_Konyvek) IS
  BEGIN
    NULL;
  END inoutp;

  /* IN OUT NOCOPY mellett */
  PROCEDURE inoutp_nocopy(p IN OUT NOCOPY T_Konyvek) IS
  BEGIN
    NULL;
  END inoutp_nocopy;

BEGIN
  /* Feltöltjük a nagyméretû változót adatokkal. */
  t0 := SYSTIMESTAMP;
  v_lista := T_Konyvek();
  FOR i IN 1..10000
  LOOP 
    v_lista.EXTEND;
    v_lista(i) := T_Tetel(1, '00-JAN.  -01');
  END LOOP;

  /* Rendre átadjuk a nagyméretû változót. */
  t1 := SYSTIMESTAMP;
  inp(v_lista);
  t2 := SYSTIMESTAMP;
  inoutp(v_lista);
  t3 := SYSTIMESTAMP;
  inoutp_nocopy(v_lista);
  t4 := SYSTIMESTAMP;

  ido(t0);
  DBMS_OUTPUT.PUT_LINE('inicializálás');
  ido(t1);
  DBMS_OUTPUT.PUT_LINE('inp');
  ido(t2);
  DBMS_OUTPUT.PUT_LINE('inoutp');
  ido(t3);
  DBMS_OUTPUT.PUT_LINE('inoutp_nocopy');
  ido(t4);
END;
/
/*
Egy eredmény: (feltéve, hogy a NOCOPY érvényben van)

16.422
inicializálás
16.458
inp
16.458
inoutp
16.482
inoutp_nocopy
16.482

A PL/SQL eljárás sikeresen befejezõdött.
*/
