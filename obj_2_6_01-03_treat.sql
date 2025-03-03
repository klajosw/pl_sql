CREATE TABLE arucikkek OF T_Arucikk;

INSERT INTO arucikkek VALUES(
  T_Kepeslap('Boldog névnapot!', 120, 40, T_Teglalap(15, 10))
);

INSERT INTO arucikkek VALUES(
  T_Toll('Filctoll', 40, 140, 'piros', 10, 0.9)
);

INSERT INTO arucikkek VALUES(
  T_Toll('Filctoll', 40, 140, 'kék', 10, 0.9)
);

INSERT INTO arucikkek VALUES(
  T_Sorkihuzo('Jo vastag sorkihuzo', 40, 140, 'zöld', 10, 0.9, 9)
);

SELECT ROWNUM, TREAT(VALUE(a) AS T_Toll).szin AS szin
  FROM arucikkek a;

/*******/

SELECT ROWNUM, TREAT(VALUE(a) AS T_Toll).szin AS szin
  FROM arucikkek a
  WHERE VALUE(a) IS OF (T_Toll);

SELECT ROWNUM, TREAT(VALUE(a) AS T_Toll).szin AS szin
  FROM arucikkek a
  WHERE VALUE(a) IS OF (ONLY T_Toll);

/*******/

CREATE TABLE cikk_refek (
  toll_ref    REF T_Toll,
  kihuzo_ref  REF T_Sorkihuzo  
);

INSERT INTO cikk_refek (toll_ref)
  SELECT TREAT(REF(a) AS REF T_Toll) FROM arucikkek a;

UPDATE cikk_refek SET kihuzo_ref = TREAT(toll_ref AS REF T_Sorkihuzo);

SELECT ROWNUM, DEREF(toll_ref), DEREF(kihuzo_ref) FROM cikk_refek;
