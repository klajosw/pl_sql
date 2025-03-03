DECLARE
  x T_Racionalis_szam;
BEGIN
  IF x IS NULL THEN
    DBMS_OUTPUT.PUT_LINE('NULL');
  END IF;
END;
/
/*
NULL

A PL/SQL eljárás sikeresen befejezõdött.
*/

DECLARE
  x T_Teglalap;
BEGIN
  DBMS_OUTPUT.PUT_LINE(x.terulet);

EXCEPTION
  WHEN SELF_IS_NULL THEN
    DBMS_OUTPUT.PUT_LINE('SELF_IS_NULL');
END;
/
/*
SELF_IS_NULL

A PL/SQL eljárás sikeresen befejezõdött.
*/

DECLARE
  x T_Racionalis_szam;
BEGIN
  DBMS_OUTPUT.PUT_LINE('.' || x.szamlalo || '.');

EXCEPTION
  WHEN ACCESS_INTO_NULL THEN
    DBMS_OUTPUT.PUT_LINE('ACCESS_INTO_NULL');
END;
/
/*
..

A PL/SQL eljárás sikeresen befejezõdött.
*/

-- Kikapcsoljuk az optimalizálót.
ALTER SESSION SET PLSQL_OPTIMIZE_LEVEL=0;

CREATE OR REPLACE PROCEDURE proc_access_into_null_teszt
IS
  x T_Racionalis_szam := NEW T_Racionalis_szam(5, 6);
  y T_Racionalis_szam;

BEGIN
  x.szamlalo := 10;
  DBMS_OUTPUT.PUT_LINE('.' || x.szamlalo || '.');
  y.szamlalo := 11;
  DBMS_OUTPUT.PUT_LINE('.' || y.szamlalo || '.');

EXCEPTION
  WHEN ACCESS_INTO_NULL THEN
    DBMS_OUTPUT.PUT_LINE('ACCESS_INTO_NULL');
END proc_access_into_null_teszt;
/

EXEC proc_access_into_null_teszt;
/*
.10.
ACCESS_INTO_NULL

A PL/SQL eljárás sikeresen befejezõdött.
*/

-- Visszakapcsoljuk az optimalizálót.
ALTER SESSION SET PLSQL_OPTIMIZE_LEVEL=2;
ALTER PROCEDURE proc_access_into_null_teszt COMPILE;

-- Ha így futtatjuk újra, az értékadás megtörténik 
-- egy az optimalizáló által bevezetett ideiglenes memóriabeli
-- változóban, mintha y.szamláló egy külön INTEGER változó lenne.
EXEC proc_access_into_null_teszt;
/*
.10.
.11.

A PL/SQL eljárás sikeresen befejezõdött.
*/


DECLARE
  x T_Racionalis_szam;
  y T_Racionalis_szam;

  PROCEDURE kiir(z T_Racionalis_szam) IS
  BEGIN
    DBMS_OUTPUT.PUT_LINE('.' || z.szamlalo || '.');
  END kiir;

  PROCEDURE init(
    p_Szamlalo INTEGER, 
    p_Nevezo   INTEGER, 
    z          OUT T_Racionalis_szam) IS
  BEGIN
    z := NEW T_Racionalis_szam(p_Szamlalo, p_Nevezo);
    z.egyszerusit;
  END init;

  PROCEDURE modosit(
    p_Szamlalo INTEGER, 
    p_Nevezo   INTEGER, 
    z          IN OUT T_Racionalis_szam) IS
  BEGIN
    z.szamlalo := p_Szamlalo;
    z.nevezo   := p_Nevezo;
    z.egyszerusit;
  END modosit;

BEGIN
  x := NEW T_Racionalis_szam(1, 2);
  kiir(x);

  init(2, 3, x);
  kiir(x);

  kiir(y);
  init(3, 4, y);
  kiir(y);

  modosit(4, 5, x);
  kiir(x);
  y := NULL;
  modosit(5, 6, y);
  kiir(y);

EXCEPTION
  WHEN ACCESS_INTO_NULL THEN
    DBMS_OUTPUT.PUT_LINE('Error: ACCESS_INTO_NULL');
    DBMS_OUTPUT.PUT_LINE('  SQLCODE:' || SQLCODE);
    DBMS_OUTPUT.PUT_LINE('  SQLERRM:' || SQLERRM);
    DBMS_OUTPUT.PUT_LINE('Error backtrace:');
    DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
END;
/
/*
.1.
.2.
..
.3.
.4.
Error: ACCESS_INTO_NULL
  SQLCODE:-6530
  SQLERRM:ORA-06530: Incializálatlan összetett objektumra való hivatkozás
Error backtrace:
ORA-06512: a(z) helyen a(z) 24. sornál
ORA-06512: a(z) helyen a(z) 43. sornál

A PL/SQL eljárás sikeresen befejezõdött.
*/

