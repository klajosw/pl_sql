CREATE OR REPLACE PACKAGE notesz
  AUTHID CURRENT_USER

  /*
     A csomag segítségével idõpontokhoz és
     személyekhez kötött feljegyzéseket
     készíthetünk és kezelhetünk.

     A csomag képes létrehozni a szükséges táblákat
     natív dinamikus SQL segítségével, mivel a
     csomag eljárásai a hívó nevében futnak le.
  */
AS

  /************************************************/
  /* A csomag által nyújtott típusok, deklarációk */
  /************************************************/

  -- Egy feljegyzés formátuma
  TYPE t_feljegyzes IS RECORD(
    idopont     DATE,
    szemely     VARCHAR2(20),
    szoveg      VARCHAR2(3000),
    torles_ido  DATE
  );

  -- Egy általános REF CURSOR
  TYPE t_refcursor IS REF CURSOR;

  -- Egy feljegyzes rekord, a %TYPE-okhoz
  v_Feljegyzes t_feljegyzes;

  -- Kollekciótípusok
  TYPE t_feljegyzes_lista IS TABLE OF t_feljegyzes;
  TYPE t_szemely_lista    IS TABLE OF v_Feljegyzes.szemely%TYPE;
  TYPE t_szam_lista       IS TABLE OF NUMBER;
  
  -- A hibás argumentum esetén az alprogramok kiválthatják
  -- a hibas_argumentum kivételt.
  hibas_argumentum  EXCEPTION;
  PRAGMA EXCEPTION_INIT(hibas_argumentum, -20200);

  /******************************************/
  /* A csomag által nyújtott szolgáltatások */
  /******************************************/

  -- A használt séma nevét állíthatjuk át
  PROCEDURE init_sema(p_Sema VARCHAR2 DEFAULT USER);

  -- Létrehozza a táblát az aktuális sémában
  PROCEDURE tabla_letrehoz;

  -- Eldobja a táblát az aktuális sémában
  PROCEDURE tabla_torol;

  -- Bejegyez egy feljegyzést és visszaadja egy rekordban
  FUNCTION feljegyez(
    p_Idopont      v_Feljegyzes.idopont%TYPE,
    p_Szoveg       v_Feljegyzes.szoveg%TYPE,
    p_Torles_ido   v_Feljegyzes.torles_ido%TYPE DEFAULT NULL,
    p_Szemely      v_Feljegyzes.szemely%TYPE DEFAULT USER
  ) RETURN t_feljegyzes;

  -- Megnyitja és visszaadja az adott személy feljegyzéseit a
  -- napra. Ha a személy NULL, akkor az összes feljegyzést megadja.
  FUNCTION feljegyzesek(
    p_Idopont      v_Feljegyzes.idopont%TYPE DEfAULT SYSDATE,
    p_Szemely      v_Feljegyzes.szemely%TYPE DEFAULT NULL
  ) RETURN t_refcursor;

  -- Visszaadja egy táblában az adott személy feljegyzéseinek számát a
  -- napra. Ekkor p_Nevek és p_Szamok egy-egy elemet tartalmaznak.
  -- Ha a p_Szemely NULL, akkor az összes feljegyzést visszadja a napra,
  -- p_Nevek és p_Szamok megegyezõ elemszámúak lesznek.
  PROCEDURE feljegyzes_lista(
    p_Nevek        OUT NOCOPY t_szemely_lista,
    p_Szamok       OUT NOCOPY t_szam_lista,
    p_Idopont      v_Feljegyzes.idopont%TYPE DEFAULT SYSDATE,
    p_Szemely      v_Feljegyzes.szemely%TYPE DEFAULT NULL
  );

  -- Kilistázza az adott személy feljegyzéseit a
  -- napra. Ha a személy NULL, akkor az összes feljegyzést megadja.
  PROCEDURE feljegyzesek_listaz(
    p_Idopont      v_Feljegyzes.idopont%TYPE DEFAULT SYSDATE,
    p_Szemely      v_Feljegyzes.szemely%TYPE DEFAULT NULL
  );

  -- Megadja az idõben elsõ feljegyzés idõpontját
  PROCEDURE elso_feljegyzes(
    p_Datum   OUT DATE
  );

  -- A paraméterben megadja az elsõ olyan feljegyzés idõpontját,
  -- amely idõpontja nagyobb, mint a p_Datum.
  -- NULL-t ad vissza, ha nincs ilyen.
  PROCEDURE kovetkezo_feljegyzes(
    p_Datum   IN OUT DATE
  );

  -- Megadja az idõben utolsó feljegyzés idõpontját
  PROCEDURE utolso_feljegyzes(
    p_Datum   OUT DATE
  );

  -- A paraméterben megadja az elsõ olyan feljegyzés idõpontját,
  -- amely idõpontja kisebb, mint a p_Datum.
  -- NULL-t ad vissza, ha nincs ilyen.
  PROCEDURE elozo_feljegyzes(
    p_Datum   IN OUT DATE
  );

  -- Törli a törlési idõvel megjelölt és lejárt feljegyzéseket és
  -- visszaadja a törölt elemek számát.
  FUNCTION torol_lejart RETURN NUMBER;

  -- Törli a megadott személyek összes feljegyzéseit és visszaadja
  -- az egyes ügyfelekhez a törölt elemek számát.
  PROCEDURE feljegyzesek_torol (
    p_Szemely_lista        t_szemely_lista,
    p_Szam_lista           OUT NOCOPY t_szam_lista
  );

END notesz;
/
show errors
