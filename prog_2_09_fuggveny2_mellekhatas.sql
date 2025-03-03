DECLARE
  i     NUMBER;
  j     NUMBER;
  k     NUMBER;

  /* 
    Ennek a függvénynek van pár mellékhatása.
  */
  FUNCTION mellekhatas(
    p1     NUMBER,
    /* OUT és IN OUT módú paraméterek nem lehetnek
       egy tiszta függvényben. 
       Minden értéket a visszatérési értékben kellene
       visszadni. Ez rekorddal megtehetõ, amennyiben
       tényleg szükséges. */
    p2     OUT NUMBER,
    p3     IN OUT NUMBER,
    p4     IN OUT NUMBER
  ) RETURN NUMBER IS
  BEGIN
    i := 10;  -- globális változó megváltoztatása
    DBMS_OUTPUT.PUT_LINE('Egy tiszta függvény nem ír a kimenetére sem.');
    p2 := 20; 
    p3 := 30;
    p4 := p3;

    RETURN 50;
  END mellekhatas;

BEGIN
  i := 0;
  j := mellekhatas(j, j, j, k);
  /* Mennyi most i, j és k értéke? */
  DBMS_OUTPUT.PUT_LINE('i= ' || i);
  DBMS_OUTPUT.PUT_LINE('j= ' || j);
  DBMS_OUTPUT.PUT_LINE('k= ' || k);
END;
/

/*
Eredmény:

Egy tiszta függvény nem ír a kimenetére sem.
i= 10
j= 50
k= 30

A PL/SQL eljárás sikeresen befejezõdött.
*/  
