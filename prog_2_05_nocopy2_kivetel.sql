DECLARE

  v_Szam       NUMBER;

  /* OUT NOCOPY nélkül */
  PROCEDURE outp(p OUT NUMBER) IS
  BEGIN
    p := 10;
    RAISE VALUE_ERROR; -- kivétel
  END outp;

  /* OUT NOCOPY mellett */
  PROCEDURE outp_nocopy(p OUT NOCOPY NUMBER) IS
  BEGIN
    p := 10;
    RAISE VALUE_ERROR; -- kivétel
  END outp_nocopy;

BEGIN
  v_Szam := 0;
  BEGIN
    outp(v_Szam);
  EXCEPTION
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('1: ' || v_Szam);
  END;

  v_Szam := 0;
  BEGIN
    outp_nocopy(v_Szam);
  EXCEPTION
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('2: ' || v_Szam);
  END;
END;
/
/*
Eredmény: (feltéve, hogy a NOCOPY érvényben van)

1: 0
2: 10

A PL/SQL eljárás sikeresen befejezõdött.

Magyarázat:
Az eljáráshívásokban kivétel következik be. Így egyik eljárás sem sikeres.
outp hívása esetén így elmarad a formális paraméternek az aktuálisba
történõ másolása.
outp_nocopy hívásakor azonban az aktuális paraméter megegyezik a formálissal, 
így az értékadás eredményes lesz az aktuális paraméterre nézve.
*/
