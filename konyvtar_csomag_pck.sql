CREATE OR REPLACE PACKAGE konyvtar_csomag
AS
  /******************************************/
  /* Mindenki számára elérhetõ deklarációk. */
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

  /* Megadja az adott dátum szerint lejárt
     kölcsönzésekhez a kölcsönzési rekordot és
     a lejárat óta eltelt napok számát.
     Ha nem adunk meg dátumot, akkor az aktuális
     dátum lesz a kezdeti érték. 

     Megjegyzés: a törzs nélküli kurzor deklarációnak
       visszatérési típussal kell rendelkeznie
   */
  CURSOR cur_lejart_kolcsonzesek(
    p_Datum DATE DEFAULT SYSDATE
  ) RETURN t_lejart_rec;

  /* Egy új ügyfélnek mindig ennyi lesz a kvótája. */
  c_Max_konyv_init           CONSTANT NUMBER := 5;

  /* Az alprogramok által kiváltott kivételek. */
  hibas_argumentum           EXCEPTION;
  PRAGMA EXCEPTION_INIT(hibas_argumentum, -20100);
  ervenytelen_kolcsonzes     EXCEPTION;
  PRAGMA EXCEPTION_INIT(ervenytelen_kolcsonzes, -20110);
  kurzor_hasznalatban        EXCEPTION;
  PRAGMA EXCEPTION_INIT(kurzor_hasznalatban, -20120);


  /*************************************************/
  /* A könyvtárban használatos gyakori alprogramok */
  /*************************************************/

  /*
     Megadja az ügyfelet az azonosítóhoz. 
     Nemlétezõ ügyfél esetén hibas_argumentum kivételt vált ki.
  */
  FUNCTION az_ugyfel(p_Ugyfel ugyfel.id%TYPE) RETURN ugyfel%ROWTYPE;

  /*
     Megadja a könyvet az azonosítóhoz. 
     Nemlétezõ könyv esetén hibas_argumentum kivételt vált ki.
  */
  FUNCTION a_konyv(p_Konyv konyv.id%TYPE) RETURN konyv%ROWTYPE;

  /* 
    Felvesz egy ügyfelet a könyvtárba a szokásos
    kezdeti kvótával és aktuális dátummal, a
    kölcsönzött könyvek oszlopot üres kollekcióra állítja.
    
    Visszatérési értéke az új ügyfél azonosítója.
  */
  FUNCTION uj_ugyfel(
    p_Nev           ugyfel.nev%TYPE,
    p_Anyja_neve    ugyfel.anyja_neve%TYPE,
    p_Lakcim        ugyfel.lakcim%TYPE,
    p_Tel_szam      ugyfel.tel_szam%TYPE,
    p_Foglalkozas   ugyfel.foglalkozas%TYPE
  ) RETURN ugyfel.id%type;

  /* 
    Raktárra vesz az adott ISBN kódú könyvbõl megadott példányt.

    Ha van már ilyen könyv, akkor hozzáadja az új készletet
    a régihez. Ilyenkor csak az ISBN számot egyezteti,
    a többi paraméter értékét a függvény nem veszi figyelembe.
    
    Visszatérési érték a könyvek azonosítója.
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
    Egy ügyfél számára kölcsönöz egy könyvet.
     - felveszi a kölcsönzési rekordot a kolcsonzes táblába
       és az ugyfel.konyvek beágyazott táblába.
     - aktualizálja az ügyfél kvótáját és a könyv szabad 
       példányainak számát.

    Nemlétezõ könyv, illetve ügyfél esetén hibas_argumentum kivétel,
    ha az ügyfélnek 0 a kvótája, vagy nincs szabad példány, akkor
    ervenytelen_kolcsonzes kivétel váltódik ki.
  */
  PROCEDURE kolcsonoz(
    p_Ugyfel        ugyfel.id%TYPE,
    p_Konyv         konyv.id%TYPE
  );

  /*
    Adminisztrálja egy könyv visszahozatalát:
     - naplózza a kölcsönzést a kolcsonzes_naplo táblában
     - törli a kölcsönzési rekordot a kolcsonzes táblából
       és az ugyfel.konyvek beágyazott táblából.
     - aktualizálja a könyv szabad példányainak számát.

    Ha a paraméterek nem jelölnek valódi kölcsönzési
    bejegyzést, akkor hibas_argumentum kivétel váltódik ki.
  */
  PROCEDURE visszahoz(
    p_Ugyfel        ugyfel.id%TYPE,
    p_Konyv         konyv.id%TYPE
  );

  /*
    Adminisztrálja egy ügyfél összes könyvének visszahozatalát:
     - naplózza a kölcsönzéseket a kolcsonzes_naplo táblában
     - törli a kölcsönzési rekordokat a kolcsonzes táblából
       és az ugyfel.konyvek beágyazott táblából.
     - aktualizálja a könyvek szabad példányainak számát.

    Ha az ügyfél nem létezik, hibas_argumentum kivétel váltódik ki.

    Megj.: Ez az eljárásnév túl van terhelve.
  */
  PROCEDURE visszahoz(
    p_Ugyfel        ugyfel.id%TYPE
  );

  /*
    Kilistázza a lejárt kölcsönzési rekordokat.

    Ha a cur_lejart_kolcsonzesek kurzor nyitva van,
    az eljárás nem használható. Ilyenkor 
    kurzor_hasznalatban kivétel váltódik ki.
  */
  PROCEDURE lejart_konyvek;

  /*
    Kilistázza a lejárt kölcsönzési rekordok közül
    azokat, amelyek ma jártak le.

    Ha a cur_lejart_kolcsonzesek kurzor nyitva van,
    az eljárás nem használható. Ilyenkor 
    kurzor_hasznalatban kivétel váltódik ki.
  */
  PROCEDURE mai_lejart_konyvek;

  /*
     Megadja egy kölcsönzött könyv hátralevõ kölcsönzési idejét.

     hibas_argumentum kivételt vált ki, ha nincs ilyen kölcsönzés.
   */
  FUNCTION hatralevo_napok(
    p_Ugyfel      ugyfel.id%TYPE, 
    p_Konyv       konyv.id%TYPE
  ) RETURN INTEGER;


  /*******************************************************************/
  /* A csomag használatára vonatkozó statisztikát kezelõ alprogramok */
  /*******************************************************************/

  /*
    Megadja a statisztikát a legutóbbi nullázás, ill.
    az indulás óta.
  */
  FUNCTION statisztika RETURN t_statisztika_rec;

  /*
    Kiírja a statisztikát a legutóbbi nullázás ill.
    az indulás óta.
  */
  PROCEDURE print_statisztika;
  
  /*
    Nullázza a statiszikát.
  */
  PROCEDURE statisztika_nullaz;

  
END konyvtar_csomag;
/
show errors
