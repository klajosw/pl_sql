/*
  A DBA naplózza a felhasználók
  be- és kijelentkezéseit a következõ 
  tábla és triggerek segítségével.
*/
CREATE TABLE felhasznalok_log (
  Felhasznalo     VARCHAR2(30),
  Esemeny         VARCHAR2(30),
  Hely            VARCHAR2(30),
  Idopont         TIMESTAMP
)
/

CREATE OR REPLACE PROCEDURE felhasznalok_log_bejegyez(
  p_Esemeny       felhasznalok_log.esemeny%TYPE
) IS
BEGIN
  INSERT INTO felhasznalok_log VALUES (
    ORA_LOGIN_USER, p_Esemeny,
    ORA_CLIENT_IP_ADDRESS, SYSTIMESTAMP
  );
END felhasznalok_log_bejegyez;
/

CREATE OR REPLACE TRIGGER tr_felhasznalok_log_be
  AFTER LOGON
  ON DATABASE
CALL felhasznalok_log_bejegyez('Bejelentkezés')
/

CREATE OR REPLACE TRIGGER tr_felhasznalok_log_ki
  BEFORE LOGOFF
  ON DATABASE
CALL felhasznalok_log_bejegyez('Kijelentkezés')
/

/*
  Próbáljon meg be- és kijelentkezni néhány
  felhasználóval, ha teheti különbözõ kliensekrõl,
  majd ellenõrizze a tábla tartalmát.
*/
   
