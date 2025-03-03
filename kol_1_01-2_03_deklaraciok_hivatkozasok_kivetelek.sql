DECLARE
  
  /* Kollekciót nem tartalmazó kollekciók */

  -- asszociatív tömb, BINARY_INTEGER index
  TYPE t_kolcsonzesek_at_binint IS 
    TABLE OF kolcsonzes%ROWTYPE
      INDEX BY BINARY_INTEGER;

  -- asszociatív tömb, PLS_INTEGER index,
  -- szerkezete egyezik az elõzõ típussal, de nem azonos típus
  TYPE t_kolcsonzesek_at_plsint IS 
    TABLE OF kolcsonzes%ROWTYPE
      INDEX BY PLS_INTEGER;

  -- asszociatív tömb, VARCHAR2 index, nem rekord típusú elemek
  TYPE t_konyv_idk_at_vc2 IS 
    TABLE OF konyv.id%TYPE
      INDEX BY konyv.isbn%TYPE; -- VARCHAR2(30)

  -- beágyazott tábla 
  TYPE t_kolcsonzesek_bt IS
    TABLE OF kolcsonzes%ROWTYPE;

  -- dinamikus tömb, objektumot tartalmaz
  -- megj.: Hasonlítsa össze a T_Konyvek adatbázistípussal 
  TYPE t_konyvlista IS
     VARRAY(10) OF T_Tetel;

  -- Nem rekordot tartalmazó kollekció 
  TYPE t_vektor IS TABLE OF NUMBER
    INDEX BY BINARY_INTEGER;

  /* Kollekciók kollekciói */
  
  -- mátrix, mindkét dimenziójában szétszórt!
  TYPE t_matrix IS TABLE OF t_vektor
    INDEX BY BINARY_INTEGER;

  -- a konyv tábla egyik oszlopa kollekció
  TYPE t_konyvek_bt IS TABLE OF konyv%ROWTYPE;


  /* Változódeklarációk és inicializációk */

  -- segédváltozók
  v_Tetel          T_Tetel;
  v_Szam           NUMBER;
  v_Szerzo         VARCHAR2(50);
  v_ISBN           konyv.isbn%TYPE;
  
  -- asszociatív tömböket nem lehet inicializálni
  v_Kolcsonzesek_at_binint1  t_kolcsonzesek_at_binint;
  v_Kolcsonzesek_at_binint2  t_kolcsonzesek_at_binint;
  v_Kolcsonzesek_at_plsint   t_kolcsonzesek_at_plsint;
  v_Konyv_id_by_ISBN         t_konyv_idk_at_vc2;

  v_Vektor      t_vektor;
  v_Matrix      t_matrix;
 

  -- Ha nincs inicializáció, akkor a beágyazott tábla és a
  -- dinamikus tömb NULL kezdõértéket kap
  v_Konyvek_N      t_konyvek_bt;
  v_Konyvlista_N   t_konyvlista;

  -- beágyazott táblát és dinamikus tõmbõt lehet inicializálni
  -- Megj.: v_Konyvlista_I 2 elemû lesz az inicializálás után
  v_Konyvek_I      t_konyvek_bt := t_konyvek_bt();
  v_Konyvlista_I   t_konyvlista := t_konyvlista(T_Tetel(10, SYSDATE), 
                                                T_Tetel(15, SYSDATE));
  -- Lehet adatbázisbeli kollekciót is használni
  v_Konyvek_ab     T_Konyvek    := T_Konyvek();
  -- Ha a tábla elemei skalár típusúak, akkor az inicializálás:
  v_Szerzok_ab     T_Szerzok    := T_Szerzok('P. Howard', NULL, 'Rejtõ Jenõ');

  /*
     Rekordelemû (nem objektum és nem skalár)
     kollekció is inicializálható megfelelõ elemekkel.

     Megj.: rekord változó NEM lehet NULL, ha
     inicializációnál NULL-t adunk meg, akkor az adott elem minden mezõje 
     NULL lesz.
   */

  -- Megfelelõ rekordtípusú elemek
  v_Kolcsonzes1    kolcsonzes%ROWTYPE;
  FUNCTION a_kolcsonzes(
    p_Kolcsonzo    kolcsonzes.kolcsonzo%TYPE,
    p_Konyv        kolcsonzes.konyv%TYPE
  ) RETURN kolcsonzes%ROWTYPE;

  -- Az inicializáció
  v_Kolcsonzesek_bt   t_kolcsonzesek_bt
    := t_kolcsonzesek_bt(v_Kolcsonzes1, a_kolcsonzes(15, 20));

  -- A függvény implementációja  
  FUNCTION a_kolcsonzes(
    p_Kolcsonzo    kolcsonzes.kolcsonzo%TYPE,
    p_Konyv        kolcsonzes.konyv%TYPE
  ) RETURN kolcsonzes%ROWTYPE IS
    v_Kolcsonzes   kolcsonzes%ROWTYPE;
  BEGIN
    SELECT * INTO v_Kolcsonzes
      FROM kolcsonzes
      WHERE kolcsonzo = p_Kolcsonzo
        AND konyv = p_Konyv;
    RETURN v_Kolcsonzes;
  END a_kolcsonzes;


  /* Kollekciót visszaadó függvény */
  FUNCTION fv_kol(
    p_Null_legyen BOOLEAN
  ) RETURN t_konyvlista IS
  BEGIN
    RETURN CASE
             WHEN p_Null_legyen THEN NULL
             ELSE v_Konyvlista_I
           END;
  END fv_kol;

BEGIN
  /* hivatkozás kollekció elemére: */

  DBMS_OUTPUT.PUT_LINE(v_Kolcsonzesek_bt(2).kolcsonzo);
  DBMS_OUTPUT.PUT_LINE(fv_kol(FALSE)(1).konyv_id);

  -- értékadás lekérdezéssel
  SELECT *
    INTO v_Kolcsonzesek_at_binint1(100)
    FROM kolcsonzes
   WHERE ROWNUM <=1;

  -- Értékadás a teljes kollekció másolásával.
  --   Ez költséges mûvelet, OUT és IN OUT módú paramétereknél
  --   fontoljuk meg a NOCOPY használatát.
  v_Kolcsonzesek_at_binint2 := v_Kolcsonzesek_at_binint1;

  -- A következõ értékadás fordítási hibát okozna, mert 
  -- a szerkezeti egyezõség nem elég az értékadáshoz:
  --
  --   v_Kolcsonzesek_at_plsint := v_Kolcsonzesek_at_binint1;
  --

  -- a v_ISBN segédváltozó inicializálása
  SELECT isbn 
    INTO v_ISBN
    FROM konyv 
   WHERE cim like 'A teljesség felé'
  ;
        
  -- értékadás karakteres indexû asszociatív tábla egy elemének
  SELECT id
    INTO v_Konyv_id_by_ISBN(v_ISBN)
    FROM konyv
   WHERE isbn = v_ISBN
  ;
  -- elem hibatkozása
  DBMS_OUTPUT.PUT_LINE('ISBN: "' || v_ISBN 
     || '", id: ' || v_Konyv_id_by_ISBN(v_ISBN)); 

  -- A v_Matrix elemeit sakktáblaszerûen feltöltjük. 
  <<blokk1>>
  DECLARE
    k     PLS_INTEGER;
  BEGIN
    k := 1;
    FOR i IN 1..8 LOOP
      FOR j IN 1..4 LOOP
        v_Matrix(i)(j*2 - i MOD 2) := k;
        k := k + 1;
      END LOOP;
    END LOOP;
  END blokk1;

  /* Kivételek illegális hivatkozások esetén */
  
  -- inicializálatlan elemre hivatkozás  
  <<blokk2>>
  BEGIN
    v_Szam := v_Matrix(20)(20);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      DBMS_OUTPUT.PUT_LINE('Kivétel blokk2-ben: ' || SQLERRM);
  END blokk2;

  v_Szerzo := v_Szerzok_ab(2); -- Létezõ elem, értéke NULL

  <<blokk3>>
  BEGIN
    v_Tetel := v_Konyvlista_I(3); -- Nem létezõ elem
  EXCEPTION
    WHEN SUBSCRIPT_BEYOND_COUNT THEN
      DBMS_OUTPUT.PUT_LINE('Kivétel blokk3-ban: ' || SQLERRM);
  END blokk3;

  <<blokk4>>
  BEGIN
    -- t_konyvlista dinamikus tömb maximális mérete 10
    v_Tetel := v_Konyvlista_I(20); -- A maximális méreten túl hivatkozunk
  EXCEPTION
    WHEN SUBSCRIPT_OUTSIDE_LIMIT THEN
      DBMS_OUTPUT.PUT_LINE('Kivétel blokk4-ben: ' || SQLERRM);
  END blokk4;

  /* Kivétel NULL kollekció esetén */
  <<blokk5>>
  BEGIN
    -- v_Konyvlista_N nem volt explicit inicializálva, értéke NULL.
    v_Tetel := v_Konyvlista_N(1);
  EXCEPTION
    WHEN COLLECTION_IS_NULL THEN
      DBMS_OUTPUT.PUT_LINE('Kivétel blokk5-ben: ' || SQLERRM);
  END blokk5;

  /* Nem asszociatív tömb kollekciók NULL tesztelése lehetséges */
  IF v_Konyvlista_N IS NULL THEN
    DBMS_OUTPUT.PUT_LINE('v_Konyvlista_N null volt.');
  END IF;

  IF v_Konyvlista_I IS NOT NULL THEN
    DBMS_OUTPUT.PUT_LINE('v_Konyvlista_I nem volt null.');
  END IF;

  /* Csak beágyazott táblák egyenlõsége vizsgálható, és csak akkor,
     ha az elemeik is összehasonlíthatók. */
  DECLARE
    TYPE t_vektor_bt IS TABLE OF NUMBER;
    v_Vektor_bt  t_vektor_bt := t_vektor_bt(1,2,3);
  BEGIN
    IF v_Vektor_bt = v_Vektor_bt THEN
      DBMS_OUTPUT.PUT_LINE('Egyenlõség...');
    END IF;
  END;

  /* A rekordot tartalmazó beágyazott tábla és bármilyen elemû dinamikus
     tömb vagy assziciatív tömb egyenlõségvizsgálata fordítási hibát
     eredményezne. Például ez is:

    IF v_Matrix(1) = v_Vektor THEN
      DBMS_OUTPUT.PUT_LINE('Egyenlõség...');
    END IF;
  */
END;
/

/*
Eredmény:

15
10
ISBN: "ISBN 963 8453 09 5", id: 10
Kivétel blokk2-ben: ORA-01403: nem talált adatot
Kivétel blokk3-ban: ORA-06533: Számlálón kívüli index érték
Kivétel blokk4-ben: ORA-06532: Határon kívüli index
Kivétel blokk5-ben: ORA-06531: Inicializálatlan gyûjtõre való hivatkozás
v_Konyvlista_N null volt.
v_Konyvlista_I nem volt null.
Egyenlõség...

A PL/SQL eljárás sikeresen befejezõdött.

*/
