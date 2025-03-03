-- Lefordítjuk sikeresen az eljárást, hogy szép kódot lássunk majd.
ALTER PROCEDURE proc_preproc COMPILE PLSQL_CCFLAGS='debug:1';

SET SERVEROUTPUT ON FORMAT WRAPPED;

BEGIN
  DBMS_PREPROCESSOR.PRINT_POST_PROCESSED_SOURCE(
      object_type => 'PROCEDURE'
    , schema_name => 'PLSQL'
    , object_name => 'PROC_PREPROC'
  );
END;
/

/*
Az eljárás módosítva.

PROCEDURE proc_preproc
IS
BEGIN

    DBMS_OUTPUT.PUT_LINE('Van DEBUG');






  DBMS_OUTPUT.PUT_LINE('Kód');
END proc_preproc;

A PL/SQL eljárás sikeresen befejezõdött.
*/
