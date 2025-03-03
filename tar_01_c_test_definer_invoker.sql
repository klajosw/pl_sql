CONNECT plsql/plsql

GRANT EXECUTE ON visszahoz TO plsql2;
GRANT EXECUTE ON visszahoz_current_user TO plsql2;

CONNECT plsql2/plsql2

CALL plsql.visszahoz(1,1);
/*
CALL plsql.visszahoz(1,1)
     *
Hiba a(z) 1. sorban:
ORA-20020: Nem l�tezik ilyen k�lcs�nz�si bejegyz�s
ORA-06512: a(z) "PLSQL.VISSZAHOZ", helyen a(z) 24. sorn�l
*/

CALL plsql.visszahoz_current_user(1,1);
/*
CALL plsql.visszahoz_current_user(1,1)
     *
Hiba a(z) 1. sorban:
ORA-00942: a t�bla vagy a n�zet nem l�tezik
ORA-06512: a(z) "PLSQL.VISSZAHOZ_CURRENT_USER", helyen a(z) 18. sorn�l
*/
