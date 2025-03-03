-- A script futtatásához DBA szerep szükséges

SPOOL sema_letrehozas.log

CREATE USER plsql IDENTIFIED BY plsql
DEFAULT TABLESPACE users
/
GRANT CONNECT, RESOURCE, 
      CREATE VIEW, DEBUG CONNECT SESSION,
      ADMINISTER DATABASE TRIGGER,
      SELECT ANY DICTIONARY
   TO plsql
/

CONNECT plsql/plsql
@bev_2_01_create
@bev_2_02_insert
@bev_2_03_view_ugyfel_konyv

SPOOL OFF

@bev_2_04_list_ugyfel_konyv
