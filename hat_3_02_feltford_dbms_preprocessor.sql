-- Leford�tjuk sikeresen az elj�r�st, hogy sz�p k�dot l�ssunk majd.
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
Az elj�r�s m�dos�tva.

PROCEDURE proc_preproc
IS
BEGIN

    DBMS_OUTPUT.PUT_LINE('Van DEBUG');






  DBMS_OUTPUT.PUT_LINE('K�d');
END proc_preproc;

A PL/SQL elj�r�s sikeresen befejez�d�tt.
*/
