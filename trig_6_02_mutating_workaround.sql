/*
  Egy lehetséges megoldás.

  Úgy törlünk, hogy az azonosítót -1-re módosítjuk,
  triggereken keresztül pedig elvégezzük a tényleges
  törlést.

  Szükségünk van egy temporális táblára,
  ezt egy csomagban tároljuk majd.
  Elsõ menetben ebben összegyûjtjük a törlendõ elemeket.
  Második menetben módosítjuk a gyerekeket,
  aztán végül elvégezzük a tényleges törlést.
*/
CREATE OR REPLACE PACKAGE pkg_fa
IS
  TYPE t_torlendo IS TABLE OF fa%ROWTYPE
    INDEX BY BINARY_INTEGER;
  v_Torlendo   t_torlendo;
  v_Torles     BOOLEAN := FALSE;

  /* Megadja egy törlésre kerülõ elem
     végsõ szülõjét, hiszen az õ szülõjét is
     lehet, hogy törlik. */
  FUNCTION szulo_torles_utan(p_Id NUMBER)
  RETURN NUMBER;
END pkg_fa;
/

CREATE OR REPLACE PACKAGE BODY pkg_fa
IS
  FUNCTION szulo_torles_utan(p_Id NUMBER)
  RETURN NUMBER IS
    v_Id     NUMBER := p_Id;
    v_Szulo  NUMBER;
  BEGIN
    WHILE v_Torlendo.EXISTS(v_Id) LOOP
      v_Id := v_Torlendo(v_Id).szulo;
    END LOOP;
    RETURN v_Id;
  END szulo_torles_utan;
END pkg_fa;
/

-- utasítás szintû BEFORE trigger inicializálja
-- a csomagváltozót
CREATE OR REPLACE TRIGGER tr_fa1
  BEFORE UPDATE OF id ON fa
BEGIN
  IF NOT pkg_fa.v_Torles THEN
    pkg_fa.v_Torlendo.DELETE;
  END IF;
END tr_fa1;
/

-- sor szintû trigger tárolja a törlendõ elemeket
CREATE OR REPLACE TRIGGER tr_fa
  BEFORE UPDATE OF id ON fa
  FOR EACH ROW
  WHEN (NEW.id = -1)
BEGIN
  IF NOT pkg_fa.v_Torles 
  THEN
    pkg_fa.v_Torlendo(:OLD.id).id    := :OLD.id;
    pkg_fa.v_Torlendo(:OLD.id).szulo := :OLD.szulo;
    pkg_fa.v_Torlendo(:OLD.id).adat  := :OLD.adat;
    -- nem módosítunk, hogy az integritás rendben legyen
    :NEW.id := :OLD.id; 
  END IF;
END tr_fa;
/
show errors

-- utasítás szintû AFTER trigger végzi el a munka
-- oroszlánrészét
CREATE OR REPLACE TRIGGER tr_fa2
  AFTER UPDATE OF id ON fa
DECLARE
  v_Id   NUMBER;
BEGIN
  IF NOT pkg_fa.v_Torles AND pkg_fa.v_Torlendo.COUNT > 0
  THEN
    pkg_fa.v_Torles := TRUE;

    -- Gyerekek átállítása
    v_Id := pkg_fa.v_Torlendo.FIRST;
    WHILE v_Id IS NOT NULL LOOP
      UPDATE fa SET szulo = pkg_fa.szulo_torles_utan(v_Id)
        WHERE szulo = v_Id;
      v_Id := pkg_fa.v_Torlendo.NEXT(v_Id);
    END LOOP;

    -- Törlés
    v_Id := pkg_fa.v_Torlendo.FIRST;
    WHILE v_Id IS NOT NULL LOOP
      DELETE FROM fa 
        WHERE id = v_Id;
      v_Id := pkg_fa.v_Torlendo.NEXT(v_Id);
    END LOOP;

    pkg_fa.v_Torles := FALSE;
  END IF;
END tr_fa2;
/

/*
Emlékeztetõül a fa:

ELEM
---------------------
+--(1, 10)
|  +--(2, 20)
|  |  +--(3, 30)
|  |  |  +--(5, 50)
|  |  +--(4, 40)
|  +--(6, 60)
|  +--(7, 70)
+--(8, 80)
|  +--(9, 90)

*/
UPDATE fa SET id = -1 
  WHERE id IN (2, 3, 8);
/*
3 sor módosítva.
*/

SELECT LPAD(' ', (LEVEL-1)*3, '|  ') || '+--' 
        || '(' || id || ', ' || adat || ')' AS elem
  FROM fa
  CONNECT BY PRIOR id = szulo
  START WITH szulo IS NULL;

/*
ELEM
--------------
+--(1, 10)
|  +--(4, 40)
|  +--(5, 50)
|  +--(6, 60)
|  +--(7, 70)
+--(9, 90)

6 sor kijelölve.
*/
