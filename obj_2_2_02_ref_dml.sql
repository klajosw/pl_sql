INSERT INTO szemelyek VALUES ('Kiss Aranka', '123456');
INSERT INTO szemelyek VALUES (T_Szemely('József István', '454545'));
INSERT INTO hitel_ugyfelek VALUES ('Nagy István', '789878');
INSERT INTO hitel_ugyfelek VALUES ('Kocsis Sándor', '789878');

SELECT nev, telefon FROM hitel_ugyfelek;
SELECT * FROM szemelyek;

UPDATE szemelyek SET telefon = '111111'
  WHERE nev = 'Kiss Aranka';

UPDATE szemelyek sz SET sz = T_Szemely('Kiss Aranka', '222222')
  WHERE sz.nev = 'Kiss Aranka';

