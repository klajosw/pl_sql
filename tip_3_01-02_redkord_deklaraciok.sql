DECLARE
  /* Rekorddefiníciók */

  -- NOT NULL megszorítás és értékadás
  TYPE t_aru_tetel IS RECORD (
    kod         NUMBER NOT NULL := 0,
    nev         VARCHAR2(20),
    afa_kulcs   NUMBER := 0.25
  );

  -- Az elõzõvel azonos szerkezetû rekord
  TYPE t_aru_bejegyzes IS RECORD (
    kod         NUMBER NOT NULL := 0,
    nev         VARCHAR2(20),
    afa_kulcs   NUMBER := 0.25
  );

  -- %ROWTYPE és rekordban rekord
  TYPE t_kolcsonzes_rec IS RECORD (
    bejegyzes   plsql.kolcsonzes%ROWTYPE,
    kolcsonzo   plsql.ugyfel%ROWTYPE,
    konyv       plsql.konyv%ROWTYPE
  );

  -- %ROWTYPE
  SUBTYPE t_ugyfel_rec IS plsql.ugyfel%ROWTYPE; 
  
  v_Tetel1      t_aru_tetel; -- Itt nem lehet inicializálás és NOT NULL!
  v_Tetel2      t_aru_tetel;

  v_Bejegyzes   t_aru_bejegyzes;

  -- %TYPE
  v_Kod         v_Tetel1.kod%TYPE := 10;

  v_Kolcsonzes  t_kolcsonzes_rec;

  /* Függvény, ami rekordot ad vissza */
  FUNCTION fv(
    p_Kolcsonzo v_Kolcsonzes.kolcsonzo.id%TYPE,
    p_Konyv     v_Kolcsonzes.konyv.id%TYPE
  ) RETURN t_kolcsonzes_rec IS
    v_Vissza    t_kolcsonzes_rec;
  BEGIN
    v_Vissza.kolcsonzo.id  := p_Kolcsonzo;
    v_Vissza.konyv.id      := p_Konyv;
    RETURN v_Vissza;
  END;

BEGIN
  /* Hivatkozás rekord mezõjére minõsítéssel */
  v_Tetel1.kod := 1;
  v_Tetel1.nev := 'alma';
  v_Tetel1.nev := INITCAP(v_Tetel1.nev);

  v_Kolcsonzes.konyv.id := fv(10, 15).konyv.id;

  /* Megengedett az értékadás azonos típusok esetén. */
  v_Tetel2 := v_Tetel1;

  /* A szerkezeti egyezõség nem elég értékadásnál */
  -- v_Bejegyzes := v_Tetel1; -- Hibás értékadás

  /* Rekordok egyenlõségének összehasonlítása és NULL tesztelése
     nem lehetséges */
  /* A következõ IF feltétele hibás

  IF v_Tetel1 IS NULL
     OR v_Tetel1 = v_Tetel2
     OR v_Tetel1 <> v_Tetel2 THEN 

    NULL;
  END IF;
  */
END;
/
