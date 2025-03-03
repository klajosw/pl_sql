CREATE OR REPLACE FUNCTION kombinacio(
  n   NUMBER,
  m   NUMBER
)
RETURN NUMBER
DETERMINISTIC
AS
BEGIN
  RETURN faktorialis(n)/faktorialis(n-m)/faktorialis(m);
END kombinacio;
/
show errors
