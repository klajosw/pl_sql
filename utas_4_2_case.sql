/* Case 1 - szelektor_kifejez�s van, az els� egyez� �rt�k� �g fut le,
        az �gakban tetsz�leges �rt�k� kifejez�s szerepelhet.
*/
DECLARE
  v_Allat       VARCHAR2(10);
BEGIN
  v_Allat := 'hal';

  CASE v_Allat || 'maz'
    WHEN 'hall�' THEN 
      DBMS_OUTPUT.PUT_LINE('A hall� nem is �llat.');
    WHEN SUBSTR('halmazelm�let', 1, 6) THEN
      DBMS_OUTPUT.PUT_LINE('A halmaz sem �llat.');
    WHEN 'halmaz' THEN
      DBMS_OUTPUT.PUT_LINE('Ez m�r nem fut le.');
    ELSE
      DBMS_OUTPUT.PUT_LINE('Most ez sem fut le.');
  END CASE;
END;
/

/* Case 2 - szelektor_kifejez�s van, nincs egyez� �g, nincs ELSE */
BEGIN
  CASE 2
    WHEN 1 THEN 
      DBMS_OUTPUT.PUT_LINE('2 = 1');
    WHEN 1+2 THEN
      DBMS_OUTPUT.PUT_LINE('2 = 1 + 2 = ' || (1+2));
  END CASE;
  -- kiv�tel: ORA-06592, azaz CASE_NOT_FOUND
END;
/

/* Case 3 - A CASE utas�t�s c�mk�zhet�. */
BEGIN
  -- A CASE �gai c�mk�zhet�k
  <<elso_elagazas>>
  CASE 1
    WHEN 1 THEN

      <<masodik_elagazas>>
      CASE 2
        WHEN 2 THEN
          DBMS_OUTPUT.PUT_LINE('Megtal�ltuk.');
      END CASE masodik_elagazas;

  END CASE elso_elagazas;
END;
/

/* Case 4 - Nincs szelektor_kifejez�s, az �gakban felt�tel szerepel. */
DECLARE
  v_Szam        NUMBER;
BEGIN
  v_Szam := 10;

  CASE
    WHEN v_Szam MOD 2 = 0 THEN
      DBMS_OUTPUT.PUT_LINE('P�ros.');
    WHEN v_Szam < 5 THEN
      DBMS_OUTPUT.PUT_LINE('Kisebb 5-n�l.');
    WHEN v_Szam > 5 THEN
      DBMS_OUTPUT.PUT_LINE('Nagyobb 5-n�l.');
    ELSE
      DBMS_OUTPUT.PUT_LINE('Ez csak az 5 lehet.');
  END CASE;
END;
/
