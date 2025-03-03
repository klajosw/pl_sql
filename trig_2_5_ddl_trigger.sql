/*
  Egy csomagváltozóban számláljuk a munkamenetben 
  végrehajtott sikeres és sikertelen CREATE és DROP
  utasításokat.
*/
CREATE OR REPLACE PACKAGE ddl_szamlalo
IS
  v_Sikeres_create      NUMBER := 0;
  v_Sikertelen_create   NUMBER := 0;
  v_Sikeres_drop        NUMBER := 0;
  v_Sikertelen_drop     NUMBER := 0;

  PROCEDURE kiir;
END ddl_szamlalo;
/

CREATE OR REPLACE PACKAGE BODY ddl_szamlalo
IS
  PROCEDURE kiir IS
  BEGIN
    DBMS_OUTPUT.PUT_LINE(RPAD('v_Sikeres_create: ', 25)
      || v_Sikeres_create);
    DBMS_OUTPUT.PUT_LINE(RPAD('v_Sikertelen_create: ', 25)
      || v_Sikertelen_create);
    DBMS_OUTPUT.PUT_LINE(RPAD('v_Sikeres_drop: ', 25)
      || v_Sikeres_drop);
    DBMS_OUTPUT.PUT_LINE(RPAD('v_Sikertelen_drop: ', 25)
      || v_Sikertelen_drop);
  END kiir;
END ddl_szamlalo;
/

CREATE OR REPLACE TRIGGER tr_ddl_szamlalo_bef
  BEFORE CREATE OR DROP
  ON plsql.SCHEMA
BEGIN
  /* Pesszimistán feltételezzük, hogy a 
     kiváltó utasítás nem lesz sikeres */
  IF ORA_SYSEVENT = 'CREATE' THEN
    ddl_szamlalo.v_Sikertelen_create := 
      ddl_szamlalo.v_Sikertelen_create + 1;
  ELSE
    ddl_szamlalo.v_Sikertelen_drop := 
      ddl_szamlalo.v_Sikertelen_drop + 1;
  END IF;
END tr_ddl_szamlalo_bef;
/

CREATE OR REPLACE TRIGGER tr_ddl_szamlalo_aft
  AFTER CREATE OR DROP
  ON plsql.SCHEMA
BEGIN
  /* Nem kellett volna pesszimistának lenni :) */
  IF ORA_SYSEVENT = 'CREATE' THEN
    ddl_szamlalo.v_Sikertelen_create := 
      ddl_szamlalo.v_Sikertelen_create - 1;
    ddl_szamlalo.v_Sikeres_create := 
      ddl_szamlalo.v_Sikeres_create + 1;
  ELSE
    ddl_szamlalo.v_Sikertelen_drop := 
      ddl_szamlalo.v_Sikertelen_drop - 1;
    ddl_szamlalo.v_Sikeres_drop := 
      ddl_szamlalo.v_Sikeres_drop + 1;
  END IF;
END tr_ddl_szamlalo_aft;
/

-- Egy sikertelen CREATE
CREATE TRIGGER tr_ddl_szamlalo_aft
/

-- Es egy sikeres CREATE
CREATE TABLE abcdefghijklm (a NUMBER)
/
-- Es egy sikeres DROP
DROP TABLE abcdefghijklm
/

CALL ddl_szamlalo.kiir();
/*
v_Sikeres_create:        1
v_Sikertelen_create:     1
v_Sikeres_drop:          1
v_Sikertelen_drop:       0
*/

/*
  Mi lesz az eredmény, ha úra létrehozzuk 
  a csomag specifikaciojat?
  Magyarázza meg az eredményt!
*/

CREATE OR REPLACE PACKAGE ddl_szamlalo
IS
  v_Sikeres_create      NUMBER := 0;
  v_Sikertelen_create   NUMBER := 0;
  v_Sikeres_drop        NUMBER := 0;
  v_Sikertelen_drop     NUMBER := 0;
  -- ez a megjegyzés itt megváltoztatja a csomagot,
  -- ezért ténlyeg újra létre kell hozni

  PROCEDURE kiir;
END ddl_szamlalo;
/
CALL ddl_szamlalo.kiir();
/*
v_Sikeres_create:        1
v_Sikertelen_create:     -1
v_Sikeres_drop:          0
v_Sikertelen_drop:       0
*/
