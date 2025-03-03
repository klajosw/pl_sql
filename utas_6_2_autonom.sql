CREATE TABLE a_tabla (
  oszlop  NUMBER
);

DECLARE

  PROCEDURE autonom(p NUMBER) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    /* Els� auton�m tranzakci� kezdete - A1 */
    INSERT INTO a_tabla VALUES(p);
    COMMIT;

    /* M�sodik auton�m tranzakci� kezdete - A2 */
    INSERT INTO a_tabla VALUES(p+1);
    COMMIT;
  END;

BEGIN
  /* Itt m�g a f� tranzakci� fut - F */
  SAVEPOINT kezdet;

  /* Az elj�r�s auton�m tranzakci�t ind�t */
  autonom(10);

  /* A f� tranzakci� visszag�rget�se */
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
