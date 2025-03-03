/*
  A DBA napl�zza a felhaszn�l�k
  be- �s kijelentkez�seit a k�vetkez� 
  t�bla �s triggerek seg�ts�g�vel.
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
CALL felhasznalok_log_bejegyez('Bejelentkez�s')
/

CREATE OR REPLACE TRIGGER tr_felhasznalok_log_ki
  BEFORE LOGOFF
  ON DATABASE
CALL felhasznalok_log_bejegyez('Kijelentkez�s')
/

/*
  Pr�b�ljon meg be- �s kijelentkezni n�h�ny
  felhaszn�l�val, ha teheti k�l�nb�z� kliensekr�l,
  majd ellen�rizze a t�bla tartalm�t.
*/
   
