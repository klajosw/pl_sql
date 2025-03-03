CREATE OR REPLACE FUNCTION faktorialis(
  n   NUMBER
)
RETURN NUMBER
DETERMINISTIC
AS
BEGIN
  IF n = 0 THEN
    RETURN 1;
  ELSIF n < 0 THEN
    RAISE_APPLICATION_ERROR(-20001, 'Hibás paraméter!');
  ELSE
    RETURN n*faktorialis(n-1);
  END IF;
END faktorialis;
/
show errors

ALTER FUNCTION kombinacio COMPILE;
