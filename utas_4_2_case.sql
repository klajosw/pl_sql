/* Case 1 - szelektor_kifejezés van, az elsõ egyezõ értékû ág fut le,
        az ágakban tetszõleges értékû kifejezés szerepelhet.
*/
DECLARE
  v_Allat       VARCHAR2(10);
BEGIN
  v_Allat := 'hal';

  CASE v_Allat || 'maz'
    WHEN 'halló' THEN 
      DBMS_OUTPUT.PUT_LINE('A halló nem is állat.');
    WHEN SUBSTR('halmazelmélet', 1, 6) THEN
      DBMS_OUTPUT.PUT_LINE('A halmaz sem állat.');
    WHEN 'halmaz' THEN
      DBMS_OUTPUT.PUT_LINE('Ez már nem fut le.');
    ELSE
      DBMS_OUTPUT.PUT_LINE('Most ez sem fut le.');
  END CASE;
END;
/

/* Case 2 - szelektor_kifejezés van, nincs egyezõ ág, nincs ELSE */
BEGIN
  CASE 2
    WHEN 1 THEN 
      DBMS_OUTPUT.PUT_LINE('2 = 1');
    WHEN 1+2 THEN
      DBMS_OUTPUT.PUT_LINE('2 = 1 + 2 = ' || (1+2));
  END CASE;
  -- kivétel: ORA-06592, azaz CASE_NOT_FOUND
END;
/

/* Case 3 - A CASE utasítás címkézhetõ. */
BEGIN
  -- A CASE ágai címkézhetõk
  <<elso_elagazas>>
  CASE 1
    WHEN 1 THEN

      <<masodik_elagazas>>
      CASE 2
        WHEN 2 THEN
          DBMS_OUTPUT.PUT_LINE('Megtaláltuk.');
      END CASE masodik_elagazas;

  END CASE elso_elagazas;
END;
/

/* Case 4 - Nincs szelektor_kifejezés, az ágakban feltétel szerepel. */
DECLARE
  v_Szam        NUMBER;
BEGIN
  v_Szam := 10;

  CASE
    WHEN v_Szam MOD 2 = 0 THEN
      DBMS_OUTPUT.PUT_LINE('Páros.');
    WHEN v_Szam < 5 THEN
      DBMS_OUTPUT.PUT_LINE('Kisebb 5-nél.');
    WHEN v_Szam > 5 THEN
      DBMS_OUTPUT.PUT_LINE('Nagyobb 5-nél.');
    ELSE
      DBMS_OUTPUT.PUT_LINE('Ez csak az 5 lehet.');
  END CASE;
END;
/
