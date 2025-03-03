CREATE OR REPLACE TYPE T_Teglalap IS OBJECT (
  a              NUMBER,
  b              NUMBER,
  MEMBER FUNCTION kerulet RETURN NUMBER,
  MEMBER FUNCTION terulet RETURN NUMBER,
  ORDER MEMBER FUNCTION meret(t T_Teglalap) RETURN NUMBER
) 
/
show errors

CREATE OR REPLACE TYPE BODY T_Teglalap AS

  MEMBER FUNCTION kerulet RETURN NUMBER IS
  BEGIN
    RETURN 2 * (a+b);
  END kerulet;

  MEMBER FUNCTION terulet RETURN NUMBER IS
  BEGIN
    RETURN a * b;
  END terulet;

  ORDER MEMBER FUNCTION meret(t T_Teglalap) RETURN NUMBER IS
  BEGIN
    RETURN CASE
             WHEN terulet < t.terulet THEN -1 -- negatív szám
             WHEN terulet > t.terulet THEN 1  -- pozitív szám
             ELSE 0
           END;
  END meret;
  
END;
/
show errors

DECLARE
  v_Teglalap1   T_Teglalap := NEW T_Teglalap(10, 20);
  v_Teglalap2   T_Teglalap := NEW T_Teglalap(22, 10);
  
  PROCEDURE kiir(s VARCHAR2, x T_Teglalap, y T_Teglalap) IS
  BEGIN
    DBMS_OUTPUT.PUT_LINE(s
      || CASE
           WHEN x < y THEN 'x < y'
           WHEN x > y THEN 'x > y'
           ELSE 'x = y'
         END);
  END kiir;

BEGIN
  kiir('1. ', v_Teglalap1, v_Teglalap2);
  kiir('2. ', v_Teglalap2, v_Teglalap1);
  kiir('3. ', v_Teglalap1, v_Teglalap1);
END;
/
/* 
Eredmény:

1. x < y
2. x > y
3. x = y

A PL/SQL eljárás sikeresen befejezõdött.
*/
