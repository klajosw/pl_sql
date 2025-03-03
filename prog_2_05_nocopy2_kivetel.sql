DECLARE

  v_Szam       NUMBER;

  /* OUT NOCOPY n�lk�l */
  PROCEDURE outp(p OUT NUMBER) IS
  BEGIN
    p := 10;
    RAISE VALUE_ERROR; -- kiv�tel
  END outp;

  /* OUT NOCOPY mellett */
  PROCEDURE outp_nocopy(p OUT NOCOPY NUMBER) IS
  BEGIN
    p := 10;
    RAISE VALUE_ERROR; -- kiv�tel
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
Eredm�ny: (felt�ve, hogy a NOCOPY �rv�nyben van)

1: 0
2: 10

A PL/SQL elj�r�s sikeresen befejez�d�tt.

Magyar�zat:
Az elj�r�sh�v�sokban kiv�tel k�vetkezik be. �gy egyik elj�r�s sem sikeres.
outp h�v�sa eset�n �gy elmarad a form�lis param�ternek az aktu�lisba
t�rt�n� m�sol�sa.
outp_nocopy h�v�sakor azonban az aktu�lis param�ter megegyezik a form�lissal, 
�gy az �rt�kad�s eredm�nyes lesz az aktu�lis param�terre n�zve.
*/
