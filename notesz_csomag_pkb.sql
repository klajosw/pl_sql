CREATE OR REPLACE PACKAGE BODY notesz
AS
  /**********************/
  /* Priv�t deklar�ci�k */
  /**********************/

  -- A s�ma nev�t t�rolja
  v_Sema        VARCHAR2(30);

  /***************************************/
  /* Publikus deklar�ci�k implement�ci�i */
  /***************************************/

  -- A haszn�lt s�ma nev�t �ll�thatjuk �t
  PROCEDURE init_sema(p_Sema VARCHAR2 DEFAULT USER) IS
  BEGIN
    v_Sema := p_Sema;
  END init_sema;

  -- L�trehozza a t�bl�t az aktu�lis s�m�ban
  PROCEDURE tabla_letrehoz
  IS
  BEGIN
    EXECUTE IMMEDIATE 'CREATE TABLE ' || v_Sema || '.notesz_feljegyzesek ('
      || 'idopont     DATE NOT NULL,'
      || 'szemely     VARCHAR2(20) NOT NULL,'
      || 'szoveg      VARCHAR2(3000),'
      || 'torles_ido  DATE'
      || ')';
  END tabla_letrehoz;
 
  -- T�rli a t�bl�t az aktu�lis s�m�ban
  PROCEDURE tabla_torol
  IS
  BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE ' || v_Sema || '.notesz_feljegyzesek';
  END tabla_torol;
 
  -- Bejegyez egy feljegyz�st �s visszaadja egy rekordban
  FUNCTION feljegyez(
    p_Idopont      v_Feljegyzes.idopont%TYPE,
    p_Szoveg       v_Feljegyzes.szoveg%TYPE,
    p_Torles_ido   v_Feljegyzes.torles_ido%TYPE DEFAULT NULL,
    p_Szemely      v_Feljegyzes.szemely%TYPE DEFAULT USER
  ) RETURN t_feljegyzes
  IS
    rv    t_feljegyzes;
  BEGIN
    IF p_Idopont IS NULL THEN
      RAISE_APPLICATION_ERROR(-20200, 
        'Nem lehet NULL az id�pont egy feljegyz�sben');
    END IF;

    EXECUTE IMMEDIATE 'INSERT INTO ' || v_Sema || '.notesz_feljegyzesek '
      || 'VALUES (:1, :2, :3, :4) '
      || 'RETURNING idopont, szemely, szoveg, torles_ido '
      ||   'INTO :5, :6, :7, :8 '
      USING p_Idopont, p_Szemely, p_Szoveg, p_Torles_ido
      RETURNING INTO rv.idopont, rv.szemely, rv.szoveg, rv.torles_ido;
      /* A RETURNING helyett lehetne a USING-ot is haszn�lni:
         USING ..., 
           OUT rv.idopont, OUT rv.szemely, OUT rv.szoveg, OUT rv.torles_ido;
        
         Az Oracle azonban a RETURNING haszn�lat�t javasolja.
      */
    RETURN rv;
  END feljegyez;

  -- Megnyitja �s visszaadja az adott szem�ly feljegyz�seit a
  -- napra. Ha a szem�ly NULL, akkor az �sszes feljegyz�st megadja.
  FUNCTION feljegyzesek(
    p_Idopont      v_Feljegyzes.idopont%TYPE DEFAULT SYSDATE,
    p_Szemely      v_Feljegyzes.szemely%TYPE DEFAULT NULL
  ) RETURN t_refcursor IS
    rv    t_refcursor;
  BEGIN
    OPEN rv FOR 
      'SELECT * FROM ' || v_Sema || '.notesz_feljegyzesek '
      || 'WHERE idopont BETWEEN :idopont AND :idopont + 1 '
      || 'AND (:szemely IS NULL OR szemely = :szemely) '
      || 'ORDER BY idopont'
      USING TRUNC(p_Idopont), TRUNC(p_Idopont), p_Szemely, p_Szemely;

    RETURN rv;
  END feljegyzesek;

  -- Visszaadja egy t�bl�ban az adott szem�ly feljegyz�seinek sz�m�t a
  -- napra. Ekkor p_Nevek �s p_Szamok egy-egy elemet tartalmaznak.
  -- Ha a p_Szemely NULL, akkor az �sszes feljegyz�st visszadja a napra,
  -- p_Nevek �s p_Szamok megegyez� elemsz�m�ak lesznek.
  PROCEDURE feljegyzes_lista(
    p_Nevek        OUT NOCOPY t_szemely_lista,
    p_Szamok       OUT NOCOPY t_szam_lista,
    p_Idopont      v_Feljegyzes.idopont%TYPE DEFAULT SYSDATE,
    p_Szemely      v_Feljegyzes.szemely%TYPE DEFAULT NULL
  ) IS
    v_Ido       VARCHAR2(10);
    v_Szemely_pred VARCHAR2(100);
    v_Datum     DATE;
  BEGIN
    v_Ido := TO_CHAR(p_Idopont, 'YYYY-MM-DD');
    v_Szemely_pred := CASE
      WHEN p_Szemely IS NULL THEN ''
      ELSE 'AND ''' || p_Szemely || ''' = szemely '
    END;
    EXECUTE IMMEDIATE 
      'SELECT szemely, COUNT(1) '
      || 'FROM ' || v_Sema || '.notesz_feljegyzesek '
      || 'WHERE idopont BETWEEN '
          || 'TO_DATE(''' || v_Ido || ''', ''YYYY-MM-DD'') '
          || 'AND TO_DATE(''' || v_Ido || ''', ''YYYY-MM-DD'') + 1 '
          || v_Szemely_pred
          || 'GROUP BY szemely'
      BULK COLLECT INTO p_Nevek, p_Szamok;
  END feljegyzes_lista;

  -- Kilist�zza az adott szem�ly feljegyz�seit a
  -- napra. Ha a szem�ly NULL, akkor az �sszes feljegyz�st megadja.
  PROCEDURE feljegyzesek_listaz (
    p_Idopont      v_Feljegyzes.idopont%TYPE DEFAULT SYSDATE,
    p_Szemely      v_Feljegyzes.szemely%TYPE DEFAULT NULL
  ) IS
    v_Feljegyzesek_cur   t_refcursor;
    v_Feljegyzes         t_feljegyzes;
  BEGIN
    v_Feljegyzesek_cur := feljegyzesek(p_Idopont, p_Szemely);
    LOOP
      FETCH v_Feljegyzesek_cur INTO v_Feljegyzes;
      EXIT WHEN v_Feljegyzesek_cur%NOTFOUND;
      DBMS_OUTPUT.PUT_LINE(v_Feljegyzesek_cur%ROWCOUNT || '. ' 
        || TO_CHAR(v_Feljegyzes.idopont, 'HH24:MI') || ', '
        || v_Feljegyzes.szemely || ', ' || v_Feljegyzes.szoveg || ', '
        || TO_CHAR(v_Feljegyzes.torles_ido, 'YYYY-MM-DD HH24:MI'));
    END LOOP;
    CLOSE v_Feljegyzesek_cur;

  END feljegyzesek_listaz;

  -- Megadja az id�ben els� feljegyz�s id�pontj�t
  PROCEDURE elso_feljegyzes(
    p_Datum   OUT DATE
  ) IS
  BEGIN
    EXECUTE IMMEDIATE 'SELECT MIN(idopont) '
      || 'FROM ' || v_Sema || '.notesz_feljegyzesek'
      INTO p_Datum;
  END elso_feljegyzes;

  -- A param�terben megadja az els� olyan feljegyz�s id�pontj�t,
  -- amely id�pontja nagyobb, mint a p_Datum.
  -- NULL-t ad vissza, ha nincs ilyen.
  PROCEDURE kovetkezo_feljegyzes(
    p_Datum   IN OUT DATE
  ) IS
  BEGIN
    EXECUTE IMMEDIATE 'SELECT MIN(idopont) '
      || 'FROM ' || v_Sema || '.notesz_feljegyzesek '
      || 'WHERE idopont > :idopont '
      INTO p_Datum
      USING p_Datum;
  END kovetkezo_feljegyzes;

  -- Megadja az id�ben utols� feljegyz�s id�pontj�t
  PROCEDURE utolso_feljegyzes(
    p_Datum   OUT DATE
  ) IS
  BEGIN
    EXECUTE IMMEDIATE 'SELECT MAX(idopont) '
      || 'FROM ' || v_Sema || '.notesz_feljegyzesek'
      INTO p_Datum;
  END utolso_feljegyzes;

  -- A param�terben megadja az els� olyan feljegyz�s id�pontj�t,
  -- amely id�pontja kisebb, mint a p_Datum.
  -- NULL-t ad vissza, ha nincs ilyen.
  PROCEDURE elozo_feljegyzes(
    p_Datum   IN OUT DATE
  ) IS
  BEGIN
    EXECUTE IMMEDIATE 'SELECT MAX(idopont) '
      || 'FROM ' || v_Sema || '.notesz_feljegyzesek '
      || 'WHERE idopont < :idopont '
      INTO p_Datum
      USING p_Datum;
  END elozo_feljegyzes;

  -- T�rli a t�rl�si id�vel megjel�lt �s lej�rt feljegyz�seket �s
  -- visszaadja a t�r�lt elemek sz�m�t.
  FUNCTION torol_lejart 
  RETURN NUMBER IS
  BEGIN
    EXECUTE IMMEDIATE 'DELETE FROM ' || v_Sema || '.notesz_feljegyzesek '
      || 'WHERE torles_ido < SYSDATE';
    RETURN SQL%ROWCOUNT;
  END torol_lejart;

  -- T�rli a megadott szem�lyek �sszes feljegyz�seit �s visszaadja
  -- az egyes �gyfelekhez a t�r�lt elemek sz�m�t.
  PROCEDURE feljegyzesek_torol (
    p_Szemely_lista        t_szemely_lista,
    p_Szam_lista           OUT NOCOPY t_szam_lista
  ) IS
  BEGIN
    FORALL i IN 1..p_Szemely_lista.COUNT
      EXECUTE IMMEDIATE 'DELETE FROM ' || v_Sema || '.notesz_feljegyzesek '
        || 'WHERE szemely = :szemely'
        USING p_Szemely_lista(i);

    p_Szam_lista := t_szam_lista();
    p_Szam_lista.EXTEND(p_Szemely_lista.COUNT);
    FOR i IN 1..p_Szam_lista.COUNT LOOP
      p_Szam_lista(i) := SQL%BULK_ROWCOUNT(i);
    END LOOP;
  END feljegyzesek_torol;

/**************************/
/* Csomag inicializ�ci�ja */
/**************************/
BEGIN
  init_sema;
END notesz;
/
show errors
