DECLARE

  SUBTYPE t_ugyfelrec IS ugyfel%ROWTYPE;
  v_Ugyfel          t_ugyfelrec;
  v_Nev             VARCHAR2(10);

  /* 
    A függvény megadja az adott keresztnevû ügyfél adatait.
    Ha nem egyértelmû a kérdés, akkor ezt kivétellel jelzi.
  */
  FUNCTION ugyfel_nevhez(p_Keresztnev VARCHAR2)
  RETURN t_ugyfelrec IS
    v_Ugyfel        t_ugyfelrec;
  BEGIN
    SELECT * INTO v_Ugyfel FROM ugyfel
      WHERE UPPER(nev) LIKE '% %' || UPPER(p_Keresztnev) || '%';
    RETURN v_Ugyfel;

  EXCEPTION
    /* Egy WHEN ág több nevesített kivételt is kezelhet. */
    WHEN NO_DATA_FOUND OR TOO_MANY_ROWS THEN
      RAISE_APPLICATION_ERROR(-20010, 
        'A keresett ügyfél nem vagy nem egyértelmûen létezik');
  END ugyfel_nevhez;

BEGIN

  FOR i IN 1..3 LOOP
    CASE i
      WHEN 1 THEN v_Nev := 'Máté';   -- Egy Máté van a könyvtárban.
      WHEN 2 THEN v_Nev := 'István'; -- Több István is van.
      WHEN 3 THEN v_Nev := 'Gergõ';  -- Nincs Gergõ nálunk.
    END CASE;

    <<blokk1>>
    BEGIN
      DBMS_OUTPUT.PUT_LINE(i || '. Keresett név: "' || v_Nev || '".');

      v_Ugyfel := ugyfel_nevhez(v_Nev);
      DBMS_OUTPUT.PUT_LINE('Nincs hiba, ügyfél: ' 
        || v_Ugyfel.nev);
    EXCEPTION
      /* Csak a WHEN OTHERS ág tudja elkapni a névtelen kivételeket. */
      WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Hiba: ' || SQLCODE || ', ' || SQLERRM);
    END blokk1;
  END LOOP;

  /* A felhasználói hiba számához is rendelhetünk kivételt. */
  <<blokk2>>
  DECLARE
    hibas_ugyfelnev   EXCEPTION;
    PRAGMA EXCEPTION_INIT(hibas_ugyfelnev, -20010);

  BEGIN
    DBMS_OUTPUT.NEW_LINE;
    DBMS_OUTPUT.PUT_LINE('Blokk2 - Szilveszter van-e?');
    v_Ugyfel := ugyfel_nevhez('Szilveszter'); -- Persze nincs.
    DBMS_OUTPUT.PUT_LINE('Igen van: ' || v_Ugyfel.nev);

  EXCEPTION
    WHEN hibas_ugyfelnev THEN
      DBMS_OUTPUT.PUT_LINE('Hiba: '
        || SQLCODE || ', ' || SQLERRM);
      RAISE; -- A hiba továbbítása
  END blokk2;

/* Mivel itt nincs kivételkezelõ, a blokk2 kivételkezelõjébõl
   továbbított kivételt a futtató rendszer kezeli. */
END;
/

/*
Eredmény:

1. Keresett név: "Máté".
Nincs hiba, ügyfél: Szabó Máté István
2. Keresett név: "István".
Hiba: -20010, ORA-20010: A keresett ügyfél nem vagy nem egyértelmûen létezik
3. Keresett név: "Gergõ".
Hiba: -20010, ORA-20010: A keresett ügyfél nem vagy nem egyértelmûen létezik

Blokk2 - Szilveszter van-e?
Hiba: -20010, ORA-20010: A keresett ügyfél nem vagy nem egyértelmûen létezik
DECLARE
*
Hiba a(z) 1. sorban:
ORA-20010: A keresett ügyfél nem vagy nem egyértelmûen létezik
ORA-06512: a(z) helyen a(z) 64. sornál

*/
