DECLARE
  /* Rekorddefin�ci�k */

  -- NOT NULL megszor�t�s �s �rt�kad�s
  TYPE t_aru_tetel IS RECORD (
    kod         NUMBER NOT NULL := 0,
    nev         VARCHAR2(20),
    afa_kulcs   NUMBER := 0.25
  );

  -- Az el�z�vel azonos szerkezet� rekord
  TYPE t_aru_bejegyzes IS RECORD (
    kod         NUMBER NOT NULL := 0,
    nev         VARCHAR2(20),
    afa_kulcs   NUMBER := 0.25
  );

  -- %ROWTYPE �s rekordban rekord
  TYPE t_kolcsonzes_rec IS RECORD (
    bejegyzes   plsql.kolcsonzes%ROWTYPE,
    kolcsonzo   plsql.ugyfel%ROWTYPE,
    konyv       plsql.konyv%ROWTYPE
  );

  -- %ROWTYPE
  SUBTYPE t_ugyfel_rec IS plsql.ugyfel%ROWTYPE; 
  
  v_Tetel1      t_aru_tetel; -- Itt nem lehet inicializ�l�s �s NOT NULL!
  v_Tetel2      t_aru_tetel;

  v_Bejegyzes   t_aru_bejegyzes;

  -- %TYPE
  v_Kod         v_Tetel1.kod%TYPE := 10;

  v_Kolcsonzes  t_kolcsonzes_rec;

  /* F�ggv�ny, ami rekordot ad vissza */
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
  /* Hivatkoz�s rekord mez�j�re min�s�t�ssel */
  v_Tetel1.kod := 1;
  v_Tetel1.nev := 'alma';
  v_Tetel1.nev := INITCAP(v_Tetel1.nev);

  v_Kolcsonzes.konyv.id := fv(10, 15).konyv.id;

  /* Megengedett az �rt�kad�s azonos t�pusok eset�n. */
  v_Tetel2 := v_Tetel1;

  /* A szerkezeti egyez�s�g nem el�g �rt�kad�sn�l */
  -- v_Bejegyzes := v_Tetel1; -- Hib�s �rt�kad�s

  /* Rekordok egyenl�s�g�nek �sszehasonl�t�sa �s NULL tesztel�se
     nem lehets�ges */
  /* A k�vetkez� IF felt�tele hib�s

  IF v_Tetel1 IS NULL
     OR v_Tetel1 = v_Tetel2
     OR v_Tetel1 <> v_Tetel2 THEN 

    NULL;
  END IF;
  */
END;
/
