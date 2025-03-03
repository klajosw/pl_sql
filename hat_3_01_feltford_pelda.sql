ALTER SESSION SET PLSQL_CCFLAGS='debug:2';

CREATE OR REPLACE PROCEDURE proc_preproc
IS
BEGIN
  $IF $$debug = 1 $THEN
    DBMS_OUTPUT.PUT_LINE('Van DEBUG');
  $ELSIF $$debug = 0 $THEN
    DBMS_OUTPUT.PUT_LINE('Nincs DEBUG');
  $ELSIF $$debug IS NOT NULL $THEN
    $ERROR 'Érvénytelen DEBUG beállítás: ' ||
        'PLSQL_CCFLGAS=' || $$PLSQL_CCFLAGS $END
  $END
  DBMS_OUTPUT.PUT_LINE('Kód');
END proc_preproc;
/
SHOW ERRORS;

/*

Figyelmeztetés: Az eljárás létrehozása fordítási hibákkal fejezõdött be.

Hibák PROCEDURE PROC_PREPROC:

LINE/COL ERROR
-------- -----------------------------------------------------------------
9/5      PLS-00179: $ERROR: Érvénytelen DEBUG beállítás:
         PLSQL_CCFLGAS=debug:2

*/


