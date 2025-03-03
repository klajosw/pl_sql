/* 
  Kölcsönös hivatkozás
*/
DECLARE
  
  PROCEDURE elj1(p NUMBER);

  PROCEDURE elj2(p NUMBER)
  IS
  BEGIN
    DBMS_OUTPUT.PUT_LINE('elj2: ' || p);
    elj1(p+1);
  END elj2;

  PROCEDURE elj1(p NUMBER)
  IS
  BEGIN
    DBMS_OUTPUT.PUT_LINE('elj1: ' || p);
    IF p = 0 THEN
      elj2(p+1);
    END IF;
  END elj1;

BEGIN
  elj1(0);
END;
/

/*
Eredmény:
elj1: 0
elj2: 1
elj1: 2

A PL/SQL eljárás sikeresen befejezõdött.

*/
