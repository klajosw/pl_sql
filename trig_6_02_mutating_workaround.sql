/*
  Egy lehets�ges megold�s.

  �gy t�rl�nk, hogy az azonos�t�t -1-re m�dos�tjuk,
  triggereken kereszt�l pedig elv�gezz�k a t�nyleges
  t�rl�st.

  Sz�ks�g�nk van egy tempor�lis t�bl�ra,
  ezt egy csomagban t�roljuk majd.
  Els� menetben ebben �sszegy�jtj�k a t�rlend� elemeket.
  M�sodik menetben m�dos�tjuk a gyerekeket,
  azt�n v�g�l elv�gezz�k a t�nyleges t�rl�st.
*/
CREATE OR REPLACE PACKAGE pkg_fa
IS
  TYPE t_torlendo IS TABLE OF fa%ROWTYPE
    INDEX BY BINARY_INTEGER;
  v_Torlendo   t_torlendo;
  v_Torles     BOOLEAN := FALSE;

  /* Megadja egy t�rl�sre ker�l� elem
     v�gs� sz�l�j�t, hiszen az � sz�l�j�t is
     lehet, hogy t�rlik. */
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

-- utas�t�s szint� BEFORE trigger inicializ�lja
-- a csomagv�ltoz�t
CREATE OR REPLACE TRIGGER tr_fa1
  BEFORE UPDATE OF id ON fa
BEGIN
  IF NOT pkg_fa.v_Torles THEN
    pkg_fa.v_Torlendo.DELETE;
  END IF;
END tr_fa1;
/

-- sor szint� trigger t�rolja a t�rlend� elemeket
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
    -- nem m�dos�tunk, hogy az integrit�s rendben legyen
    :NEW.id := :OLD.id; 
  END IF;
END tr_fa;
/
show errors

-- utas�t�s szint� AFTER trigger v�gzi el a munka
-- oroszl�nr�sz�t
CREATE OR REPLACE TRIGGER tr_fa2
  AFTER UPDATE OF id ON fa
DECLARE
  v_Id   NUMBER;
BEGIN
  IF NOT pkg_fa.v_Torles AND pkg_fa.v_Torlendo.COUNT > 0
  THEN
    pkg_fa.v_Torles := TRUE;

    -- Gyerekek �t�ll�t�sa
    v_Id := pkg_fa.v_Torlendo.FIRST;
    WHILE v_Id IS NOT NULL LOOP
      UPDATE fa SET szulo = pkg_fa.szulo_torles_utan(v_Id)
        WHERE szulo = v_Id;
      v_Id := pkg_fa.v_Torlendo.NEXT(v_Id);
    END LOOP;

    -- T�rl�s
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
Eml�keztet��l a fa:

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
3 sor m�dos�tva.
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

6 sor kijel�lve.
*/
