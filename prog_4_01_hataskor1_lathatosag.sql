<<blokk>>
DECLARE
  i     NUMBER := 1;
  p     VARCHAR2(10) := 'Hello';

  /* Az alprogramban deklar�lt i elfedi a glob�lis v�ltoz�t
     p param�ter is elfedi a k�ls� p v�ltoz�t */
  PROCEDURE alprg1(p NUMBER DEFAULT 22) IS
    i    NUMBER := 2;

    /* A lok�lis alprogram tov�bbi n�v�tk�z�seket tartalmaz. */
    PROCEDURE alprg2(p NUMBER DEFAULT 555) IS
      i    NUMBER := 3;
    BEGIN
      /* A k�vetkez� utas�t�sok szeml�ltetik a min�s�tett nevek
        haszn�lat�t. 
        A min�s�t�sek k�z�l egyed�l a 3. utas�t�s alprg2.p
        min�s�t�se felesleges (de megengedett). */
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
Eredm�ny:

1, Hello
2, 22
3, 555
4, 555

A PL/SQL elj�r�s sikeresen befejez�d�tt.
*/  
