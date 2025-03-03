-- A script futtatásához DBA szerep szükséges

CREATE USER plsql2 IDENTIFIED BY plsql2
DEFAULT TABLESPACE users
/
GRANT CONNECT, RESOURCE, CREATE VIEW TO plsql2
/
