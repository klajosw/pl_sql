<<blokk>>
DECLARE
  i     NUMBER := 1;
  p     VARCHAR2(10) := 'Hello';

  /* Az alprogramban deklarált i elfedi a globális változót
     p paraméter is elfedi a külsõ p változót */
  PROCEDURE alprg1(p NUMBER DEFAULT 22) IS
    i    NUMBER := 2;

    /* A lokális alprogram további névütközéseket tartalmaz. */
    PROCEDURE alprg2(p NUMBER DEFAULT 555) IS
      i    NUMBER := 3;
    BEGIN
      /* A következõ utasítások szemléltetik a minõsített nevek
        használatát. 
        A minõsítések közül egyedül a 3. utasítás alprg2.p
        minõsítése felesleges (de megengedett). */
      FOR i IN 4..4 LOOP
        DBMS_OUTPUT.PUT_LINE(blokk.i || ', ' || blokk.p);
        DBMS_OUTPUT.PUT_LINE(alprg1.i || ', ' || alprg1.p);
        DBMS_OUTPUT.PUT_LINE(alprg2.i || ', ' || alprg2.p);
        DBMS_OUTPUT.PUT_LINE(i || ', ' || p);
      END LOOP;
    END alprg2;

  BEGIN
    alprg2;
  END alprg1;   

BEGIN
  alprg1;
END blokk;
/

/*
Eredmény:

1, Hello
2, 22
3, 555
4, 555

A PL/SQL eljárás sikeresen befejezõdött.
*/  
