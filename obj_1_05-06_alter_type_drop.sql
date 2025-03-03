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

/* Nem lehet úgy törölni, hogy egy mezõ se maradjon. */
ALTER TYPE T_Obj DROP ATTRIBUTE mezo1;
/*
ALTER TYPE T_Obj DROP ATTRIBUTE mezo1
*
Hiba a(z) 1. sorban:
ORA-22324: a módosított típus fordítási hibákat tartalmaz
ORA-22328: A(z) "PLSQL"."T_OBJ" objektum hibákat tartalmaz.
PLS-00589: nem található attribútum a következõ objektumtípusban: "T_OBJ"
*/

ALTER TYPE T_Obj ADD ATTRIBUTE mezo2 DATE;

/* A törzs validálása */
ALTER TYPE T_Obj COMPILE DEBUG BODY REUSE SETTINGS;

ALTER TYPE T_Obj ADD 
  FINAL MEMBER PROCEDURE proc2;

/* A törzset nem elég újrafordítani... */
ALTER TYPE T_Obj COMPILE REUSE SETTINGS;
/*
Figyelmeztetés: A típus módosítása fordítási hibákkal fejezõdött be.
*/

/* ... ezért cseréljük a törzs implementációját */
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
