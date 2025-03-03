CREATE TABLE a_tabla (
  oszlop  NUMBER
);

DECLARE

  PROCEDURE autonom(p NUMBER) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    /* Elsõ autonóm tranzakció kezdete - A1 */
    INSERT INTO a_tabla VALUES(p);
    COMMIT;

    /* Második autonóm tranzakció kezdete - A2 */
    INSERT INTO a_tabla VALUES(p+1);
    COMMIT;
  END;

BEGIN
  /* Itt még a fõ tranzakció fut - F */
  SAVEPOINT kezdet;

  /* Az eljárás autonóm tranzakciót indít */
  autonom(10);

  /* A fõ tranzakció visszagörgetése */
  ROLLBACK TO kezdet;
END;
/

SELECT * FROM a_tabla;
/*
     OSZLOP
-----------
         10
         11
*/
