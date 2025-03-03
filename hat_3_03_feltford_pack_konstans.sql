ALTER SESSION SET PLSQL_CCFLAGS='konstansom_erteke:TRUE';

CREATE OR REPLACE package pack_konstansok
IS 
  c_Konstans CONSTANT BOOLEAN := $$konstansom_erteke;
END;
/

CREATE OR REPLACE PROCEDURE proc_preproc_pack
IS
BEGIN
  $IF pack_konstansok.c_Konstans $THEN
    DBMS_OUTPUT.PUT_LINE('pack_konstansok.c_konstans TRUE');
  $ELSE
    DBMS_OUTPUT.PUT_LINE('pack_konstansok.c_konstans FALSE');
  $END
END proc_preproc_pack;
/

SET SERVEROUTPUT ON FORMAT WRAPPED;
EXEC proc_preproc_pack;
-- pack_konstansok.c_konstans TRUE

-- A csomag explicit újrafordítása az eljárást érvényteleníti
ALTER PACKAGE pack_konstansok COMPILE
  PLSQL_CCFLAGS='konstansom_erteke:FALSE';

-- Most fog az eljárás újrafordulni automatikusan
EXEC proc_preproc_pack;
-- pack_konstansok.c_konstans FALSE
