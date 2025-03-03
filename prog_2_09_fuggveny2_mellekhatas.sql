DECLARE
  i     NUMBER;
  j     NUMBER;
  k     NUMBER;

  /* 
    Ennek a f�ggv�nynek van p�r mell�khat�sa.
  */
  FUNCTION mellekhatas(
    p1     NUMBER,
    /* OUT �s IN OUT m�d� param�terek nem lehetnek
       egy tiszta f�ggv�nyben. 
       Minden �rt�ket a visszat�r�si �rt�kben kellene
       visszadni. Ez rekorddal megtehet�, amennyiben
       t�nyleg sz�ks�ges. */
    p2     OUT NUMBER,
    p3     IN OUT NUMBER,
    p4     IN OUT NUMBER
  ) RETURN NUMBER IS
  BEGIN
    i := 10;  -- glob�lis v�ltoz� megv�ltoztat�sa
    DBMS_OUTPUT.PUT_LINE('Egy tiszta f�ggv�ny nem �r a kimenet�re sem.');
    p2 := 20; 
    p3 := 30;
    p4 := p3;

    RETURN 50;
  END mellekhatas;

BEGIN
  i := 0;
  j := mellekhatas(j, j, j, k);
  /* Mennyi most i, j �s k �rt�ke? */
  DBMS_OUTPUT.PUT_LINE('i= ' || i);
  DBMS_OUTPUT.PUT_LINE('j= ' || j);
  DBMS_OUTPUT.PUT_LINE('k= ' || k);
END;
/

/*
Eredm�ny:

Egy tiszta f�ggv�ny nem �r a kimenet�re sem.
i= 10
j= 50
k= 30

A PL/SQL elj�r�s sikeresen befejez�d�tt.
*/  
