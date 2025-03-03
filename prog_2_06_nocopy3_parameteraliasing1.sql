DECLARE
  v_Szam        NUMBER;

  /*
    Eredmény szerinti paraméterátadás.
    Az aktuális paraméter az alprogram befejeztével
    értékül kapja a formális paraméter értékét.
  */  
  PROCEDURE valtoztat1(p OUT NUMBER)
  IS
  BEGIN
    p := 10;
    v_Szam := 5;
  END valtoztat1;

  /*
    Referencia szerinti paraméterátadás (feltéve, hogy a NOCOPY érvényben van).
    Az aktuális paraméter megegyezik a formálissal.
    Nincs étékadás az alprogram befejezésekor.
  */
  PROCEDURE valtoztat2(p OUT NOCOPY NUMBER)
  IS
  BEGIN
    p := 10;
    v_Szam := 5;
  END valtoztat2;

BEGIN
  v_Szam := NULL;
  valtoztat1(v_Szam); -- Az alprogram végén v_Szam p értékét kapja meg
  DBMS_OUTPUT.PUT_LINE('eredmény szerint: ' || v_Szam);

  v_Szam := NULL;
  valtoztat2(v_Szam); -- Az alprogramban v_Szam és p megegyezik
  DBMS_OUTPUT.PUT_LINE('referencia szerint: ' || v_Szam);
END;
/

/*
Eredmény:

eredmény szerint: 10
referencia szerint: 5
*/
