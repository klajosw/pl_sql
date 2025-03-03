DECLARE
  v_Szam        NUMBER;

  /*
    A h�rom param�ter �tad�s�nak m�dja (felt�ve, hogy a NOCOPY �rv�nyben van):
    p1 - referencia szerinti
    p2 - �rt�k-eredm�ny szerinti
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
Eredm�ny:

    v_Szam  p1  p2  p3
--  ------  --  --  --
1:      10  10  10  10
2:      10  10  20  10
3:      30  30  20  30
4:      20

Magyar�zat:
Az elj�r�s h�v�sakor p1, p3 �s v_Szam ugyanazt a sz�m objektumot jel�lik,
p2 azonban nem. Ez�rt p2 := 20; �rt�kad�s nem v�ltoztatja meg p1-et
,�gy p3-at �s v_Szam-ot sem k�zvetlen�l. A p3 := 30; �rt�kad�s viszont
megv�ltoztatja p1-et, azaz p3-at, azaz v_Szam-ot is 30-ra.
Az elj�r�s befejezt�vel v_Szam aktu�lis param�ter megkapja p2 form�lis
param�ter �rt�k�t, az �rt�keredm�ny �tad�si m�d miatt. �gy v_Szam �rt�ke
20 lesz.
A p�lda azt is igazolja, hogy p1 is referencia szerint ker�l �tad�sra.
*/
