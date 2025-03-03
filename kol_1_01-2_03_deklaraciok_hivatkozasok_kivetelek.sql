DECLARE
  
  /* Kollekci�t nem tartalmaz� kollekci�k */

  -- asszociat�v t�mb, BINARY_INTEGER index
  TYPE t_kolcsonzesek_at_binint IS 
    TABLE OF kolcsonzes%ROWTYPE
      INDEX BY BINARY_INTEGER;

  -- asszociat�v t�mb, PLS_INTEGER index,
  -- szerkezete egyezik az el�z� t�pussal, de nem azonos t�pus
  TYPE t_kolcsonzesek_at_plsint IS 
    TABLE OF kolcsonzes%ROWTYPE
      INDEX BY PLS_INTEGER;

  -- asszociat�v t�mb, VARCHAR2 index, nem rekord t�pus� elemek
  TYPE t_konyv_idk_at_vc2 IS 
    TABLE OF konyv.id%TYPE
      INDEX BY konyv.isbn%TYPE; -- VARCHAR2(30)

  -- be�gyazott t�bla 
  TYPE t_kolcsonzesek_bt IS
    TABLE OF kolcsonzes%ROWTYPE;

  -- dinamikus t�mb, objektumot tartalmaz
  -- megj.: Hasonl�tsa �ssze a T_Konyvek adatb�zist�pussal 
  TYPE t_konyvlista IS
     VARRAY(10) OF T_Tetel;

  -- Nem rekordot tartalmaz� kollekci� 
  TYPE t_vektor IS TABLE OF NUMBER
    INDEX BY BINARY_INTEGER;

  /* Kollekci�k kollekci�i */
  
  -- m�trix, mindk�t dimenzi�j�ban sz�tsz�rt!
  TYPE t_matrix IS TABLE OF t_vektor
    INDEX BY BINARY_INTEGER;

  -- a konyv t�bla egyik oszlopa kollekci�
  TYPE t_konyvek_bt IS TABLE OF konyv%ROWTYPE;


  /* V�ltoz�deklar�ci�k �s inicializ�ci�k */

  -- seg�dv�ltoz�k
  v_Tetel          T_Tetel;
  v_Szam           NUMBER;
  v_Szerzo         VARCHAR2(50);
  v_ISBN           konyv.isbn%TYPE;
  
  -- asszociat�v t�mb�ket nem lehet inicializ�lni
  v_Kolcsonzesek_at_binint1  t_kolcsonzesek_at_binint;
  v_Kolcsonzesek_at_binint2  t_kolcsonzesek_at_binint;
  v_Kolcsonzesek_at_plsint   t_kolcsonzesek_at_plsint;
  v_Konyv_id_by_ISBN         t_konyv_idk_at_vc2;

  v_Vektor      t_vektor;
  v_Matrix      t_matrix;
 

  -- Ha nincs inicializ�ci�, akkor a be�gyazott t�bla �s a
  -- dinamikus t�mb NULL kezd��rt�ket kap
  v_Konyvek_N      t_konyvek_bt;
  v_Konyvlista_N   t_konyvlista;

  -- be�gyazott t�bl�t �s dinamikus t�mb�t lehet inicializ�lni
  -- Megj.: v_Konyvlista_I 2 elem� lesz az inicializ�l�s ut�n
  v_Konyvek_I      t_konyvek_bt := t_konyvek_bt();
  v_Konyvlista_I   t_konyvlista := t_konyvlista(T_Tetel(10, SYSDATE), 
                                                T_Tetel(15, SYSDATE));
  -- Lehet adatb�zisbeli kollekci�t is haszn�lni
  v_Konyvek_ab     T_Konyvek    := T_Konyvek();
  -- Ha a t�bla elemei skal�r t�pus�ak, akkor az inicializ�l�s:
  v_Szerzok_ab     T_Szerzok    := T_Szerzok('P. Howard', NULL, 'Rejt� Jen�');

  /*
     Rekordelem� (nem objektum �s nem skal�r)
     kollekci� is inicializ�lhat� megfelel� elemekkel.

     Megj.: rekord v�ltoz� NEM lehet NULL, ha
     inicializ�ci�n�l NULL-t adunk meg, akkor az adott elem minden mez�je 
     NULL lesz.
   */

  -- Megfelel� rekordt�pus� elemek
  v_Kolcsonzes1    kolcsonzes%ROWTYPE;
  FUNCTION a_kolcsonzes(
    p_Kolcsonzo    kolcsonzes.kolcsonzo%TYPE,
    p_Konyv        kolcsonzes.konyv%TYPE
  ) RETURN kolcsonzes%ROWTYPE;

  -- Az inicializ�ci�
  v_Kolcsonzesek_bt   t_kolcsonzesek_bt
    := t_kolcsonzesek_bt(v_Kolcsonzes1, a_kolcsonzes(15, 20));

  -- A f�ggv�ny implement�ci�ja  
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


  /* Kollekci�t visszaad� f�ggv�ny */
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
  /* hivatkoz�s kollekci� elem�re: */

  DBMS_OUTPUT.PUT_LINE(v_Kolcsonzesek_bt(2).kolcsonzo);
  DBMS_OUTPUT.PUT_LINE(fv_kol(FALSE)(1).konyv_id);

  -- �rt�kad�s lek�rdez�ssel
  SELECT *
    INTO v_Kolcsonzesek_at_binint1(100)
    FROM kolcsonzes
   WHERE ROWNUM <=1;

  -- �rt�kad�s a teljes kollekci� m�sol�s�val.
  --   Ez k�lts�ges m�velet, OUT �s IN OUT m�d� param�terekn�l
  --   fontoljuk meg a NOCOPY haszn�lat�t.
  v_Kolcsonzesek_at_binint2 := v_Kolcsonzesek_at_binint1;

  -- A k�vetkez� �rt�kad�s ford�t�si hib�t okozna, mert 
  -- a szerkezeti egyez�s�g nem el�g az �rt�kad�shoz:
  --
  --   v_Kolcsonzesek_at_plsint := v_Kolcsonzesek_at_binint1;
  --

  -- a v_ISBN seg�dv�ltoz� inicializ�l�sa
  SELECT isbn 
    INTO v_ISBN
    FROM konyv 
   WHERE cim like 'A teljess�g fel�'
  ;
        
  -- �rt�kad�s karakteres index� asszociat�v t�bla egy elem�nek
  SELECT id
    INTO v_Konyv_id_by_ISBN(v_ISBN)
    FROM konyv
   WHERE isbn = v_ISBN
  ;
  -- elem hibatkoz�sa
  DBMS_OUTPUT.PUT_LINE('ISBN: "' || v_ISBN 
     || '", id: ' || v_Konyv_id_by_ISBN(v_ISBN)); 

  -- A v_Matrix elemeit sakkt�blaszer�en felt�ltj�k. 
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

  /* Kiv�telek illeg�lis hivatkoz�sok eset�n */
  
  -- inicializ�latlan elemre hivatkoz�s  
  <<blokk2>>
  BEGIN
    v_Szam := v_Matrix(20)(20);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      DBMS_OUTPUT.PUT_LINE('Kiv�tel blokk2-ben: ' || SQLERRM);
  END blokk2;

  v_Szerzo := v_Szerzok_ab(2); -- L�tez� elem, �rt�ke NULL

  <<blokk3>>
  BEGIN
    v_Tetel := v_Konyvlista_I(3); -- Nem l�tez� elem
  EXCEPTION
    WHEN SUBSCRIPT_BEYOND_COUNT THEN
      DBMS_OUTPUT.PUT_LINE('Kiv�tel blokk3-ban: ' || SQLERRM);
  END blokk3;

  <<blokk4>>
  BEGIN
    -- t_konyvlista dinamikus t�mb maxim�lis m�rete 10
    v_Tetel := v_Konyvlista_I(20); -- A maxim�lis m�reten t�l hivatkozunk
  EXCEPTION
    WHEN SUBSCRIPT_OUTSIDE_LIMIT THEN
      DBMS_OUTPUT.PUT_LINE('Kiv�tel blokk4-ben: ' || SQLERRM);
  END blokk4;

  /* Kiv�tel NULL kollekci� eset�n */
  <<blokk5>>
  BEGIN
    -- v_Konyvlista_N nem volt explicit inicializ�lva, �rt�ke NULL.
    v_Tetel := v_Konyvlista_N(1);
  EXCEPTION
    WHEN COLLECTION_IS_NULL THEN
      DBMS_OUTPUT.PUT_LINE('Kiv�tel blokk5-ben: ' || SQLERRM);
  END blokk5;

  /* Nem asszociat�v t�mb kollekci�k NULL tesztel�se lehets�ges */
  IF v_Konyvlista_N IS NULL THEN
    DBMS_OUTPUT.PUT_LINE('v_Konyvlista_N null volt.');
  END IF;

  IF v_Konyvlista_I IS NOT NULL THEN
    DBMS_OUTPUT.PUT_LINE('v_Konyvlista_I nem volt null.');
  END IF;

  /* Csak be�gyazott t�bl�k egyenl�s�ge vizsg�lhat�, �s csak akkor,
     ha az elemeik is �sszehasonl�that�k. */
  DECLARE
    TYPE t_vektor_bt IS TABLE OF NUMBER;
    v_Vektor_bt  t_vektor_bt := t_vektor_bt(1,2,3);
  BEGIN
    IF v_Vektor_bt = v_Vektor_bt THEN
      DBMS_OUTPUT.PUT_LINE('Egyenl�s�g...');
    END IF;
  END;

  /* A rekordot tartalmaz� be�gyazott t�bla �s b�rmilyen elem� dinamikus
     t�mb vagy assziciat�v t�mb egyenl�s�gvizsg�lata ford�t�si hib�t
     eredm�nyezne. P�ld�ul ez is:

    IF v_Matrix(1) = v_Vektor THEN
      DBMS_OUTPUT.PUT_LINE('Egyenl�s�g...');
    END IF;
  */
END;
/

/*
Eredm�ny:

15
10
ISBN: "ISBN 963 8453 09 5", id: 10
Kiv�tel blokk2-ben: ORA-01403: nem tal�lt adatot
Kiv�tel blokk3-ban: ORA-06533: Sz�ml�l�n k�v�li index �rt�k
Kiv�tel blokk4-ben: ORA-06532: Hat�ron k�v�li index
Kiv�tel blokk5-ben: ORA-06531: Inicializ�latlan gy�jt�re val� hivatkoz�s
v_Konyvlista_N null volt.
v_Konyvlista_I nem volt null.
Egyenl�s�g...

A PL/SQL elj�r�s sikeresen befejez�d�tt.

*/
