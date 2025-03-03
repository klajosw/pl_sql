DECLARE

  SUBTYPE t_ugyfelrec IS ugyfel%ROWTYPE;
  v_Ugyfel          t_ugyfelrec;
  v_Nev             VARCHAR2(10);

  /* 
    A f�ggv�ny megadja az adott keresztnev� �gyf�l adatait.
    Ha nem egy�rtelm� a k�rd�s, akkor ezt kiv�tellel jelzi.
  */
  FUNCTION ugyfel_nevhez(p_Keresztnev VARCHAR2)
  RETURN t_ugyfelrec IS
    v_Ugyfel        t_ugyfelrec;
  BEGIN
    SELECT * INTO v_Ugyfel FROM ugyfel
      WHERE UPPER(nev) LIKE '% %' || UPPER(p_Keresztnev) || '%';
    RETURN v_Ugyfel;

  EXCEPTION
    /* Egy WHEN �g t�bb neves�tett kiv�telt is kezelhet. */
    WHEN NO_DATA_FOUND OR TOO_MANY_ROWS THEN
      RAISE_APPLICATION_ERROR(-20010, 
        'A keresett �gyf�l nem vagy nem egy�rtelm�en l�tezik');
  END ugyfel_nevhez;

BEGIN

  FOR i IN 1..3 LOOP
    CASE i
      WHEN 1 THEN v_Nev := 'M�t�';   -- Egy M�t� van a k�nyvt�rban.
      WHEN 2 THEN v_Nev := 'Istv�n'; -- T�bb Istv�n is van.
      WHEN 3 THEN v_Nev := 'Gerg�';  -- Nincs Gerg� n�lunk.
    END CASE;

    <<blokk1>>
    BEGIN
      DBMS_OUTPUT.PUT_LINE(i || '. Keresett n�v: "' || v_Nev || '".');

      v_Ugyfel := ugyfel_nevhez(v_Nev);
      DBMS_OUTPUT.PUT_LINE('Nincs hiba, �gyf�l: ' 
        || v_Ugyfel.nev);
    EXCEPTION
      /* Csak a WHEN OTHERS �g tudja elkapni a n�vtelen kiv�teleket. */
      WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Hiba: ' || SQLCODE || ', ' || SQLERRM);
    END blokk1;
  END LOOP;

  /* A felhaszn�l�i hiba sz�m�hoz is rendelhet�nk kiv�telt. */
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
      RAISE; -- A hiba tov�bb�t�sa
  END blokk2;

/* Mivel itt nincs kiv�telkezel�, a blokk2 kiv�telkezel�j�b�l
   tov�bb�tott kiv�telt a futtat� rendszer kezeli. */
END;
/

/*
Eredm�ny:

1. Keresett n�v: "M�t�".
Nincs hiba, �gyf�l: Szab� M�t� Istv�n
2. Keresett n�v: "Istv�n".
Hiba: -20010, ORA-20010: A keresett �gyf�l nem vagy nem egy�rtelm�en l�tezik
3. Keresett n�v: "Gerg�".
Hiba: -20010, ORA-20010: A keresett �gyf�l nem vagy nem egy�rtelm�en l�tezik

Blokk2 - Szilveszter van-e?
Hiba: -20010, ORA-20010: A keresett �gyf�l nem vagy nem egy�rtelm�en l�tezik
DECLARE
*
Hiba a(z) 1. sorban:
ORA-20010: A keresett �gyf�l nem vagy nem egy�rtelm�en l�tezik
ORA-06512: a(z) helyen a(z) 64. sorn�l

*/
