DECLARE
  v_Szam        NUMBER;

  /*
    Eredm�ny szerinti param�ter�tad�s.
    Az aktu�lis param�ter az alprogram befejezt�vel
    �rt�k�l kapja a form�lis param�ter �rt�k�t.
  */  
  PROCEDURE valtoztat1(p OUT NUMBER)
  IS
  BEGIN
    p := 10;
    v_Szam := 5;
  END valtoztat1;

  /*
    Referencia szerinti param�ter�tad�s (felt�ve, hogy a NOCOPY �rv�nyben van).
    Az aktu�lis param�ter megegyezik a form�lissal.
    Nincs �t�kad�s az alprogram befejez�sekor.
  */
  PROCEDURE valtoztat2(p OUT NOCOPY NUMBER)
  IS
  BEGIN
    p := 10;
    v_Szam := 5;
  END valtoztat2;

BEGIN
  v_Szam := NULL;
  valtoztat1(v_Szam); -- Az alprogram v�g�n v_Szam p �rt�k�t kapja meg
  DBMS_OUTPUT.PUT_LINE('eredm�ny szerint: ' || v_Szam);

  v_Szam := NULL;
  valtoztat2(v_Szam); -- Az alprogramban v_Szam �s p megegyezik
  DBMS_OUTPUT.PUT_LINE('referencia szerint: ' || v_Szam);
END;
/

/*
Eredm�ny:

eredm�ny szerint: 10
referencia szerint: 5
*/
