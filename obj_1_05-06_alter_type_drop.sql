CREATE TYPE T_Obj IS OBJECT (
  mezo1   NUMBER,
  MEMBER PROCEDURE proc1
)
/

CREATE TYPE BODY T_Obj AS

  MEMBER PROCEDURE proc1 IS
  BEGIN
    DBMS_OUTPUT.PUT_LINE('proc1');
  END proc1;

END;
/

/* Nem lehet �gy t�r�lni, hogy egy mez� se maradjon. */
ALTER TYPE T_Obj DROP ATTRIBUTE mezo1;
/*
ALTER TYPE T_Obj DROP ATTRIBUTE mezo1
*
Hiba a(z) 1. sorban:
ORA-22324: a m�dos�tott t�pus ford�t�si hib�kat tartalmaz
ORA-22328: A(z) "PLSQL"."T_OBJ" objektum hib�kat tartalmaz.
PLS-00589: nem tal�lhat� attrib�tum a k�vetkez� objektumt�pusban: "T_OBJ"
*/

ALTER TYPE T_Obj ADD ATTRIBUTE mezo2 DATE;

/* A t�rzs valid�l�sa */
ALTER TYPE T_Obj COMPILE DEBUG BODY REUSE SETTINGS;

ALTER TYPE T_Obj ADD 
  FINAL MEMBER PROCEDURE proc2;

/* A t�rzset nem el�g �jraford�tani... */
ALTER TYPE T_Obj COMPILE REUSE SETTINGS;
/*
Figyelmeztet�s: A t�pus m�dos�t�sa ford�t�si hib�kkal fejez�d�tt be.
*/

/* ... ez�rt cser�lj�k a t�rzs implement�ci�j�t */
CREATE OR REPLACE TYPE BODY T_Obj AS

  MEMBER PROCEDURE proc1 IS
  BEGIN
    DBMS_OUTPUT.PUT_LINE('proc1');
  END proc1;

  FINAL MEMBER PROCEDURE proc2 IS
  BEGIN
    DBMS_OUTPUT.PUT_LINE('proc2');
  END proc2;

END;
/

DROP TYPE T_Obj;
