CREATE TABLE tab1 (
  id   NUMBER NOT NULL,
  nev  VARCHAR2(40)
)
/

DECLARE
  -- rekordt�pus� alt�pus
  SUBTYPE t_tabsor IS tab1%ROWTYPE;

  -- t_nev �r�kli a tabl1.nev hosszmegszor�t�s�t
  SUBTYPE t_nev IS tab1.nev%TYPE NOT NULL;

  -- t_id nem �r�kli a tab1.id NOT NULL megszor�t�s�t,
  -- mivel ez t�blamegszor�t�s, nem a t�pushoz tartozik.
  SUBTYPE t_id IS tab1.id%TYPE;

  -- t_nev2 �r�kli a tab1.nev hosszmegszor�t�s�t �s NOT NULL
  -- megszor�t�s�t is, mert PL/SQL t�pus eset�n a NOT NULL
  -- is a t�pushoz tartozik.
  SUBTYPE t_nev2 IS t_nev;

  v_Id    t_id;                 -- NUMBER t�pus�, NULL kezd��rt�kkel

  v_Nev1  t_nev;                -- hib�s, ford�t�si hiba, NOT NULL t�pusn�l
                                -- mindig k�telez� az �rt�kad�s

  v_Nev2  t_nev := 'XY';        -- �gy mar j�

BEGIN
  v_Id   := NULL;   -- megengedett, lehet NULL
  v_Nev2 := NULL;   -- hib�s, NULL-t nem lehet �rt�k�l adni
END;
/

DECLARE
  -- RANGE megszor�t�s alt�pusban
  SUBTYPE t_szamjegy10 IS BINARY_INTEGER RANGE 0..9;
  v_Szamjegy10  t_szamjegy10;
  v_Szamjegy16  BINARY_INTEGER RANGE 0..15;

BEGIN
  -- megengedett �rt�kad�sok
  v_Szamjegy10   := 9;
  v_Szamjegy16   := 15;

  -- hib�s �rt�kad�sok, mindkett� fut�si idej� hib�t v�ltana ki
--  v_Szamjegy10 := 10;
--  v_Szamjegy16 := 16;
END;
/
