DECLARE
  -- kollekciótípus
  TYPE t_szamok IS TABLE OF NUMBER
        INDEX BY BINARY_INTEGER;

  v_Szam        NUMBER;

  -- rekord típusú változó
  v_Konyv       konyv%ROWTYPE;
  v_Konyv2      v_Konyv%TYPE;

  v_KonyvId     konyv.id%TYPE;

  v_Szamok      t_szamok;
BEGIN
  v_Szam       := 10.4;
  v_Konyv.id   := 15;
  v_Konyv2     := v_Konyv;      -- Rekordok értékadása
  v_KonyvId    := v_Konyv2.id;  -- értéke 15
  v_Szamok(4)  := v_Szam;
END;
/
