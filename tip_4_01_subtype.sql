CREATE TABLE tab1 (
  id   NUMBER NOT NULL,
  nev  VARCHAR2(40)
)
/

DECLARE
  -- rekordtípusú altípus
  SUBTYPE t_tabsor IS tab1%ROWTYPE;

  -- t_nev örökli a tabl1.nev hosszmegszorítását
  SUBTYPE t_nev IS tab1.nev%TYPE NOT NULL;

  -- t_id nem örökli a tab1.id NOT NULL megszorítását,
  -- mivel ez táblamegszorítás, nem a típushoz tartozik.
  SUBTYPE t_id IS tab1.id%TYPE;

  -- t_nev2 örökli a tab1.nev hosszmegszorítását és NOT NULL
  -- megszorítását is, mert PL/SQL típus esetén a NOT NULL
  -- is a típushoz tartozik.
  SUBTYPE t_nev2 IS t_nev;

  v_Id    t_id;                 -- NUMBER típusú, NULL kezdõértékkel

  v_Nev1  t_nev;                -- hibás, fordítási hiba, NOT NULL típusnál
                                -- mindig kötelezõ az értékadás

  v_Nev2  t_nev := 'XY';        -- így mar jó

BEGIN
  v_Id   := NULL;   -- megengedett, lehet NULL
  v_Nev2 := NULL;   -- hibás, NULL-t nem lehet értékül adni
END;
/

DECLARE
  -- RANGE megszorítás altípusban
  SUBTYPE t_szamjegy10 IS BINARY_INTEGER RANGE 0..9;
  v_Szamjegy10  t_szamjegy10;
  v_Szamjegy16  BINARY_INTEGER RANGE 0..15;

BEGIN
  -- megengedett értékadások
  v_Szamjegy10   := 9;
  v_Szamjegy16   := 15;

  -- hibás értékadások, mindkettõ futási idejû hibát váltana ki
--  v_Szamjegy10 := 10;
--  v_Szamjegy16 := 16;
END;
/
