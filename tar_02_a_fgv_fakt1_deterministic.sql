CREATE OR REPLACE FUNCTION faktorialis(
  n   NUMBER
)
RETURN NUMBER
DETERMINISTIC
AS
  rv    NUMBER;
BEGIN
  IF n < 0 THEN
    RAISE_APPLICATION_ERROR(-20001, 'Hibás paraméter!');
  END IF;

  rv := 1;
  FOR i IN 1..n LOOP
    rv := rv * i;
  END LOOP;
  RETURN rv;
END faktorialis;
/
show errors
