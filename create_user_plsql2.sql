-- A script futtat�s�hoz DBA szerep sz�ks�ges

CREATE USER plsql2 IDENTIFIED BY plsql2
DEFAULT TABLESPACE users
/
GRANT CONNECT, RESOURCE, CREATE VIEW TO plsql2
/
