ALTER SESSION SET PLSQL_CCFLAGS='debug:2';

CREATE OR REPLACE PROCEDURE proc_preproc
IS
BEGIN
  $IF $$debug = 1 $THEN
    DBMS_OUTPUT.PUT_LINE('Van DEBUG');
  $ELSIF $$debug = 0 $THEN
    DBMS_OUTPUT.PUT_LINE('Nincs DEBUG');
  $ELSIF $$debug IS NOT NULL $THEN
    $ERROR '�rv�nytelen DEBUG be�ll�t�s: ' ||
        'PLSQL_CCFLGAS=' || $$PLSQL_CCFLAGS $END
  $END
  DBMS_OUTPUT.PUT_LINE('K�d');
END proc_preproc;
/
SHOW ERRORS;

/*

Figyelmeztet�s: Az elj�r�s l�trehoz�sa ford�t�si hib�kkal fejez�d�tt be.

Hib�k PROCEDURE PROC_PREPROC:

LINE/COL ERROR
-------- -----------------------------------------------------------------
9/5      PLS-00179: $ERROR: �rv�nytelen DEBUG be�ll�t�s:
         PLSQL_CCFLGAS=debug:2

*/


