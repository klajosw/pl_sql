CREATE OR REPLACE PACKAGE konyvtar_csomag
AS
  /******************************************/
  /* Mindenki sz�m�ra el�rhet� deklar�ci�k. */
  /******************************************/

  TYPE t_statisztika_rec IS RECORD (
    uj_ugyfelek           NUMBER := 0,
    uj_konyvek            NUMBER := 0,
    kolcsonzesek          NUMBER := 0,
    visszahozott_konyvek  NUMBER := 0,
    utolso_modositas      DATE := SYSDATE,
    utolso_nullazas       DATE := SYSDATE
  );

  TYPE t_lejart_rec IS RECORD (
    kolcsonzo       kolcsonzes.kolcsonzo%TYPE,
    konyv           kolcsonzes.kolcsonzo%TYPE,
    datum           kolcsonzes.datum%TYPE,
    hosszabbitva    kolcsonzes.hosszabbitva%TYPE,
    megjegyzes      kolcsonzes.megjegyzes%TYPE,
    napok           INTEGER
  );

  /* Megadja az adott d�tum szerint lej�rt
     k�lcs�nz�sekhez a k�lcs�nz�si rekordot �s
     a lej�rat �ta eltelt napok sz�m�t.
     Ha nem adunk meg d�tumot, akkor az aktu�lis
     d�tum lesz a kezdeti �rt�k. 

     Megjegyz�s: a t�rzs n�lk�li kurzor deklar�ci�nak
       visszat�r�si t�pussal kell rendelkeznie
   */
  CURSOR cur_lejart_kolcsonzesek(
    p_Datum DATE DEFAULT SYSDATE
  ) RETURN t_lejart_rec;

  /* Egy �j �gyf�lnek mindig ennyi lesz a kv�t�ja. */
  c_Max_konyv_init           CONSTANT NUMBER := 5;

  /* Az alprogramok �ltal kiv�ltott kiv�telek. */
  hibas_argumentum           EXCEPTION;
  PRAGMA EXCEPTION_INIT(hibas_argumentum, -20100);
  ervenytelen_kolcsonzes     EXCEPTION;
  PRAGMA EXCEPTION_INIT(ervenytelen_kolcsonzes, -20110);
  kurzor_hasznalatban        EXCEPTION;
  PRAGMA EXCEPTION_INIT(kurzor_hasznalatban, -20120);


  /*************************************************/
  /* A k�nyvt�rban haszn�latos gyakori alprogramok */
  /*************************************************/

  /*
     Megadja az �gyfelet az azonos�t�hoz. 
     Neml�tez� �gyf�l eset�n hibas_argumentum kiv�telt v�lt ki.
  */
  FUNCTION az_ugyfel(p_Ugyfel ugyfel.id%TYPE) RETURN ugyfel%ROWTYPE;

  /*
     Megadja a k�nyvet az azonos�t�hoz. 
     Neml�tez� k�nyv eset�n hibas_argumentum kiv�telt v�lt ki.
  */
  FUNCTION a_konyv(p_Konyv konyv.id%TYPE) RETURN konyv%ROWTYPE;

  /* 
    Felvesz egy �gyfelet a k�nyvt�rba a szok�sos
    kezdeti kv�t�val �s aktu�lis d�tummal, a
    k�lcs�nz�tt k�nyvek oszlopot �res kollekci�ra �ll�tja.
    
    Visszat�r�si �rt�ke az �j �gyf�l azonos�t�ja.
  */
  FUNCTION uj_ugyfel(
    p_Nev           ugyfel.nev%TYPE,
    p_Anyja_neve    ugyfel.anyja_neve%TYPE,
    p_Lakcim        ugyfel.lakcim%TYPE,
    p_Tel_szam      ugyfel.tel_szam%TYPE,
    p_Foglalkozas   ugyfel.foglalkozas%TYPE
  ) RETURN ugyfel.id%type;

  /* 
    Rakt�rra vesz az adott ISBN k�d� k�nyvb�l megadott p�ld�nyt.

    Ha van m�r ilyen k�nyv, akkor hozz�adja az �j k�szletet
    a r�gihez. Ilyenkor csak az ISBN sz�mot egyezteti,
    a t�bbi param�ter �rt�k�t a f�ggv�ny nem veszi figyelembe.
    
    Visszat�r�si �rt�k a k�nyvek azonos�t�ja.
  */
  FUNCTION konyv_raktarba(
    p_ISBN          konyv.ISBN%TYPE,
    p_Cim           konyv.cim%TYPE,
    p_Kiado         konyv.kiado%TYPE,
    p_Kiadasi_ev    konyv.kiadasi_ev%TYPE,
    p_Szerzo        konyv.szerzo%TYPE,
    p_Darab         INTEGER
  ) RETURN konyv.id%type;

  /*
    Egy �gyf�l sz�m�ra k�lcs�n�z egy k�nyvet.
     - felveszi a k�lcs�nz�si rekordot a kolcsonzes t�bl�ba
       �s az ugyfel.konyvek be�gyazott t�bl�ba.
     - aktualiz�lja az �gyf�l kv�t�j�t �s a k�nyv szabad 
       p�ld�nyainak sz�m�t.

    Neml�tez� k�nyv, illetve �gyf�l eset�n hibas_argumentum kiv�tel,
    ha az �gyf�lnek 0 a kv�t�ja, vagy nincs szabad p�ld�ny, akkor
    ervenytelen_kolcsonzes kiv�tel v�lt�dik ki.
  */
  PROCEDURE kolcsonoz(
    p_Ugyfel        ugyfel.id%TYPE,
    p_Konyv         konyv.id%TYPE
  );

  /*
    Adminisztr�lja egy k�nyv visszahozatal�t:
     - napl�zza a k�lcs�nz�st a kolcsonzes_naplo t�bl�ban
     - t�rli a k�lcs�nz�si rekordot a kolcsonzes t�bl�b�l
       �s az ugyfel.konyvek be�gyazott t�bl�b�l.
     - aktualiz�lja a k�nyv szabad p�ld�nyainak sz�m�t.

    Ha a param�terek nem jel�lnek val�di k�lcs�nz�si
    bejegyz�st, akkor hibas_argumentum kiv�tel v�lt�dik ki.
  */
  PROCEDURE visszahoz(
    p_Ugyfel        ugyfel.id%TYPE,
    p_Konyv         konyv.id%TYPE
  );

  /*
    Adminisztr�lja egy �gyf�l �sszes k�nyv�nek visszahozatal�t:
     - napl�zza a k�lcs�nz�seket a kolcsonzes_naplo t�bl�ban
     - t�rli a k�lcs�nz�si rekordokat a kolcsonzes t�bl�b�l
       �s az ugyfel.konyvek be�gyazott t�bl�b�l.
     - aktualiz�lja a k�nyvek szabad p�ld�nyainak sz�m�t.

    Ha az �gyf�l nem l�tezik, hibas_argumentum kiv�tel v�lt�dik ki.

    Megj.: Ez az elj�r�sn�v t�l van terhelve.
  */
  PROCEDURE visszahoz(
    p_Ugyfel        ugyfel.id%TYPE
  );

  /*
    Kilist�zza a lej�rt k�lcs�nz�si rekordokat.

    Ha a cur_lejart_kolcsonzesek kurzor nyitva van,
    az elj�r�s nem haszn�lhat�. Ilyenkor 
    kurzor_hasznalatban kiv�tel v�lt�dik ki.
  */
  PROCEDURE lejart_konyvek;

  /*
    Kilist�zza a lej�rt k�lcs�nz�si rekordok k�z�l
    azokat, amelyek ma j�rtak le.

    Ha a cur_lejart_kolcsonzesek kurzor nyitva van,
    az elj�r�s nem haszn�lhat�. Ilyenkor 
    kurzor_hasznalatban kiv�tel v�lt�dik ki.
  */
  PROCEDURE mai_lejart_konyvek;

  /*
     Megadja egy k�lcs�nz�tt k�nyv h�tralev� k�lcs�nz�si idej�t.

     hibas_argumentum kiv�telt v�lt ki, ha nincs ilyen k�lcs�nz�s.
   */
  FUNCTION hatralevo_napok(
    p_Ugyfel      ugyfel.id%TYPE, 
    p_Konyv       konyv.id%TYPE
  ) RETURN INTEGER;


  /*******************************************************************/
  /* A csomag haszn�lat�ra vonatkoz� statisztik�t kezel� alprogramok */
  /*******************************************************************/

  /*
    Megadja a statisztik�t a legut�bbi null�z�s, ill.
    az indul�s �ta.
  */
  FUNCTION statisztika RETURN t_statisztika_rec;

  /*
    Ki�rja a statisztik�t a legut�bbi null�z�s ill.
    az indul�s �ta.
  */
  PROCEDURE print_statisztika;
  
  /*
    Null�zza a statiszik�t.
  */
  PROCEDURE statisztika_nullaz;

  
END konyvtar_csomag;
/
show errors
