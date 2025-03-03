DECLARE
  v_Szam        NUMBER;

  /*
    A három paraméter átadásának módja (feltéve, hogy a NOCOPY érvényben van):
    p1 - referencia szerinti
    p2 - érték-eredmény szerinti
    p3 - referencia szerinti
  */  
  PROCEDURE elj(
    p1   IN NUMBER, 
    p2   IN OUT NUMBER,
    p3   IN OUT NOCOPY NUMBER
  ) IS
  BEGIN
    DBMS_OUTPUT.PUT_LINE('1:      '||v_Szam||'  '||p1||'  '||p2||'  '||p3);
    p2 := 20;
    DBMS_OUTPUT.PUT_LINE('2:      '||v_Szam||'  '||p1||'  '||p2||'  '||p3);
    p3 := 30;
    DBMS_OUTPUT.PUT_LINE('3:      '||v_Szam||'  '||p1||'  '||p2||'  '||p3);
  END elj;

BEGIN
  DBMS_OUTPUT.PUT_LINE('    v_Szam  p1  p2  p3');
  DBMS_OUTPUT.PUT_LINE('--  ------  --  --  --');
  v_Szam := 10;
  elj(v_Szam, v_Szam, v_Szam);
  DBMS_OUTPUT.PUT_LINE('4:      ' || v_Szam);
END;
/

/*
Eredmény:

    v_Szam  p1  p2  p3
--  ------  --  --  --
1:      10  10  10  10
2:      10  10  20  10
3:      30  30  20  30
4:      20

Magyarázat:
Az eljárás hívásakor p1, p3 és v_Szam ugyanazt a szám objektumot jelölik,
p2 azonban nem. Ezért p2 := 20; értékadás nem változtatja meg p1-et
,így p3-at és v_Szam-ot sem közvetlenül. A p3 := 30; értékadás viszont
megváltoztatja p1-et, azaz p3-at, azaz v_Szam-ot is 30-ra.
Az eljárás befejeztével v_Szam aktuális paraméter megkapja p2 formális
paraméter értékét, az értékeredmény átadási mód miatt. Így v_Szam értéke
20 lesz.
A példa azt is igazolja, hogy p1 is referencia szerint kerül átadásra.
*/
