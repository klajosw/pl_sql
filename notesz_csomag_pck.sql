CREATE OR REPLACE PACKAGE notesz
  AUTHID CURRENT_USER

  /*
     A csomag seg�ts�g�vel id�pontokhoz �s
     szem�lyekhez k�t�tt feljegyz�seket
     k�sz�thet�nk �s kezelhet�nk.

     A csomag k�pes l�trehozni a sz�ks�ges t�bl�kat
     nat�v dinamikus SQL seg�ts�g�vel, mivel a
     csomag elj�r�sai a h�v� nev�ben futnak le.
  */
AS

  /************************************************/
  /* A csomag �ltal ny�jtott t�pusok, deklar�ci�k */
  /************************************************/

  -- Egy feljegyz�s form�tuma
  TYPE t_feljegyzes IS RECORD(
    idopont     DATE,
    szemely     VARCHAR2(20),
    szoveg      VARCHAR2(3000),
    torles_ido  DATE
  );

  -- Egy �ltal�nos REF CURSOR
  TYPE t_refcursor IS REF CURSOR;

  -- Egy feljegyzes rekord, a %TYPE-okhoz
  v_Feljegyzes t_feljegyzes;

  -- Kollekci�t�pusok
  TYPE t_feljegyzes_lista IS TABLE OF t_feljegyzes;
  TYPE t_szemely_lista    IS TABLE OF v_Feljegyzes.szemely%TYPE;
  TYPE t_szam_lista       IS TABLE OF NUMBER;
  
  -- A hib�s argumentum eset�n az alprogramok kiv�lthatj�k
  -- a hibas_argumentum kiv�telt.
  hibas_argumentum  EXCEPTION;
  PRAGMA EXCEPTION_INIT(hibas_argumentum, -20200);

  /******************************************/
  /* A csomag �ltal ny�jtott szolg�ltat�sok */
  /******************************************/

  -- A haszn�lt s�ma nev�t �ll�thatjuk �t
  PROCEDURE init_sema(p_Sema VARCHAR2 DEFAULT USER);

  -- L�trehozza a t�bl�t az aktu�lis s�m�ban
  PROCEDURE tabla_letrehoz;

  -- Eldobja a t�bl�t az aktu�lis s�m�ban
  PROCEDURE tabla_torol;

  -- Bejegyez egy feljegyz�st �s visszaadja egy rekordban
  FUNCTION feljegyez(
    p_Idopont      v_Feljegyzes.idopont%TYPE,
    p_Szoveg       v_Feljegyzes.szoveg%TYPE,
    p_Torles_ido   v_Feljegyzes.torles_ido%TYPE DEFAULT NULL,
    p_Szemely      v_Feljegyzes.szemely%TYPE DEFAULT USER
  ) RETURN t_feljegyzes;

  -- Megnyitja �s visszaadja az adott szem�ly feljegyz�seit a
  -- napra. Ha a szem�ly NULL, akkor az �sszes feljegyz�st megadja.
  FUNCTION feljegyzesek(
    p_Idopont      v_Feljegyzes.idopont%TYPE DEfAULT SYSDATE,
    p_Szemely      v_Feljegyzes.szemely%TYPE DEFAULT NULL
  ) RETURN t_refcursor;

  -- Visszaadja egy t�bl�ban az adott szem�ly feljegyz�seinek sz�m�t a
  -- napra. Ekkor p_Nevek �s p_Szamok egy-egy elemet tartalmaznak.
  -- Ha a p_Szemely NULL, akkor az �sszes feljegyz�st visszadja a napra,
  -- p_Nevek �s p_Szamok megegyez� elemsz�m�ak lesznek.
  PROCEDURE feljegyzes_lista(
    p_Nevek        OUT NOCOPY t_szemely_lista,
    p_Szamok       OUT NOCOPY t_szam_lista,
    p_Idopont      v_Feljegyzes.idopont%TYPE DEFAULT SYSDATE,
    p_Szemely      v_Feljegyzes.szemely%TYPE DEFAULT NULL
  );

  -- Kilist�zza az adott szem�ly feljegyz�seit a
  -- napra. Ha a szem�ly NULL, akkor az �sszes feljegyz�st megadja.
  PROCEDURE feljegyzesek_listaz(
    p_Idopont      v_Feljegyzes.idopont%TYPE DEFAULT SYSDATE,
    p_Szemely      v_Feljegyzes.szemely%TYPE DEFAULT NULL
  );

  -- Megadja az id�ben els� feljegyz�s id�pontj�t
  PROCEDURE elso_feljegyzes(
    p_Datum   OUT DATE
  );

  -- A param�terben megadja az els� olyan feljegyz�s id�pontj�t,
  -- amely id�pontja nagyobb, mint a p_Datum.
  -- NULL-t ad vissza, ha nincs ilyen.
  PROCEDURE kovetkezo_feljegyzes(
    p_Datum   IN OUT DATE
  );

  -- Megadja az id�ben utols� feljegyz�s id�pontj�t
  PROCEDURE utolso_feljegyzes(
    p_Datum   OUT DATE
  );

  -- A param�terben megadja az els� olyan feljegyz�s id�pontj�t,
  -- amely id�pontja kisebb, mint a p_Datum.
  -- NULL-t ad vissza, ha nincs ilyen.
  PROCEDURE elozo_feljegyzes(
    p_Datum   IN OUT DATE
  );

  -- T�rli a t�rl�si id�vel megjel�lt �s lej�rt feljegyz�seket �s
  -- visszaadja a t�r�lt elemek sz�m�t.
  FUNCTION torol_lejart RETURN NUMBER;

  -- T�rli a megadott szem�lyek �sszes feljegyz�seit �s visszaadja
  -- az egyes �gyfelekhez a t�r�lt elemek sz�m�t.
  PROCEDURE feljegyzesek_torol (
    p_Szemely_lista        t_szemely_lista,
    p_Szam_lista           OUT NOCOPY t_szam_lista
  );

END notesz;
/
show errors
