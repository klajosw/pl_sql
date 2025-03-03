PL/SQL (Procedural Language/SQL) - I.
=====================================

Alapok
------

- utasítást ; zárja le
- PL/SQL blokk lezárása: /
- kis- és nagybetû egyenértékû (az utasításokban a kulcsszavakat szoktuk nagybatûvel írni, de nem kötelzõ)
- comment REM vagy --, többsoros /* */
- használat elõtt deklarálni kell a változókat, azonosítókat, eljárásokat
- ** hatványozás, != nem egyenlõ, || karakterlánc összefûzés
- egy PL/SQL program egy vagy több blokkból áll, a blokkok egymásba ágyazhatók

- blokk felépítése
	DECLARE
	BEGIN
	EXCEPTION
	END;

Példa:
	VAR X NUMBER
	DECLARE
		a NUMBER;
	BEGIN
		a := 3;
		:X := a + 3;
	END;
	.
	RUN
	PRINT :X
-- . hatására befejezodik a PL/SQL blokk vége, de nem fut le automatikusan, / hatására viszont igen

Változók deklarációja: változónév [CONSTANT] adattípus [NOT NULL] [DEFAULT érték]
---------------------------------------------------------------------------------

Példa:
	DECLARE
		a CONSTANT NUMBER := 3;
		b NUMBER NOT NULL := 5;
	BEGIN
		:X := :X + a + b + 3;
	END;
	.
	RUN
	PRINT :X


DBMS_OUTPUT (PL/SQL csomag)
---------------------------

- használatát a SET SERVEROUTPUT ON SQL*Plus paranccsal engedélyezni kell
- PUT: ugyanabba a sorba ír több outputot
- NEW_LINE: sor végét jelzi 
- PUT_LINE: minden outputot külön sorba ír

Példa:
	SET SERVEROUTPUT ON
	ACCEPT nev PROMPT 'Kerem addja meg a nevét: '  
	DECLARE 
		szoveg varchar2(50);
	BEGIN
		szoveg := CONCAT('&nev',' sikeresen végrehajtotta a programot!');
		DBMS_OUTPUT.PUT_LINE (szoveg);
	END;


Változó értékadás a SELECT... INTO... utasítással
-------------------------------------------------

Példa:
	CREATE TABLE T1(
	    e INTEGER,
	    f INTEGER
	);

	INSERT INTO T1 VALUES(1, 3);
	INSERT INTO T1 VALUES(2, 4);

	DECLARE
	    a NUMBER;
	    b NUMBER;
	BEGIN
	    SELECT e,f INTO a,b FROM T1 WHERE e>1;
	    INSERT INTO T1 VALUES(b,a);
	END;


Rekordtípus, változó deklarálás adattábla típusokból
----------------------------------------------------

- %TYPE, %ROWTYPE

Példa:
	DECLARE
		v_veznev DEMO.MUNKATARS.VEZETEKNEV%TYPE;
		v_kernev DEMO.MUNKATARS.KERESZTNEV%TYPE;
	BEGIN
		SELECT vezeteknev, keresztnev
		INTO v_veznev, v_kernev
		FROM DEMO.munkatars
		WHERE vezeteknev LIKE 'Nagy'
		AND keresztnev LIKE 'Elek';
		DBMS_OUTPUT.PUT_LINE('A dolgozo teljes neve: ' || v_veznev || ' ' || v_kernev);
	END;


Példa:
	DECLARE
		v_sor DEMO.vevo%ROWTYPE;
	BEGIN
		SELECT * INTO v_sor 
		FROM DEMO.vevo 
		WHERE partner_id = 21;
		DBMS_OUTPUT.PUT_LINE(v_sor.MEGNEVEZES);
	END; 



- TYPE rekordtípusnév IS RECORD (mezõnév típus,..., mezõnév típus)

Példa:
	DECLARE
		TYPE dolgozo_rekord IS RECORD
		   (adoszam INTEGER, nev CHAR(30), lakcim VARCHAR2(50));
		egy_dolgozo dolgozo_rekord;
	BEGIN
		egy_dolgozo.nev := 'Kovacs';
	END;


Vezérlési szerkezetek
---------------------

- IF feltétel THEN, ELSIF feltétel THEN, ELSE, END IF;

Példa:
	DECLARE
		v_avgber	DEMO.munkatars.ber%TYPE;
		szoveg		VARCHAR2(50);
	begin
		SELECT AVG(ber)
		INTO v_avgber
		FROM DEMO.munkatars;
		IF v_avgber < 100000 THEN
			szoveg:='kevesebb mint szazezer';
		ELSIF (v_avgber > 100000) AND (v_avgber <= 200000) THEN
			szoveg:='szazezer es ketszazezer kozt';
		ELSE
			szoveg:='ketszazezer folott';
		END IF;
		DBMS_OUTPUT.PUT_LINE(szoveg);
	END;


- CASE valtozo, WHEN ertek THEN, ..., ELSE, END CASE; 

Példa:
	CASE num
   		WHEN 1 THEN dbms_output.put_line('Egy');
			.
			.
			.
   		WHEN 9 THEN dbms_output.put_line('Kilenc');
   		ELSE dbms_output.put_line('Nem egyjegyu');
 	END CASE;	


- LOOP, [EXIT;], [EXIT WHEN feltétel;], END LOOP;

Példa:
	DECLARE
		v_sorsz		DEMO.vevo.partner_id%TYPE := 21;
		v_megnev	DEMO.vevo.megnevezes%TYPE;
	BEGIN
		LOOP
			SELECT megnevezes
			INTO v_megnev
			FROM DEMO.vevo
			WHERE partner_id = v_sorsz;
			DBMS_OUTPUT.PUT_LINE(v_megnev);
			v_sorsz := v_sorsz +1;
		EXIT WHEN v_sorsz > 28;
		END LOOP;
	END;

	
- FOR ciklusváltozó IN [REVERSE] alsóhatár .. felsohatár LOOP, END LOOP;

Példa:
	FOR num IN 1..500 LOOP
	   INSERT INTO roots VALUES (num, SQRT(num));
	END LOOP;


- WHILE feltétel, LOOP, END LOOP;

Példa:
	DECLARE
		v_sorsz		DEMO.vevo.partner_id%TYPE := 21;
		v_megnev	DEMO.vevo.megnevezes%TYPE;
	BEGIN
		WHILE v_sorsz < 29
		LOOP
			SELECT megnevezes
			INTO v_megnev
			FROM DEMO.vevo
			WHERE partner_id = v_sorsz;
			DBMS_OUTPUT.PUT_LINE(v_megnev);
			v_sorsz := v_sorsz +1;
		END LOOP;
	END;


Gyûjtõtáblák kezelése
---------------------

- részben listaszerûen, részben tömbszerûen kezelhetõ adatstruktúra
- oszlopai: adat (oszlop vagy rekord típusú lehet), index (BINARY INTEGER)
- mérete nem korlátozott
- tömbként indexelhetõ, ahol az index NEGATÍV is lehet: adat(index)
- új sorokkal bõvíthetõ és törölhetõ --> hézagok lehetnek benne

- létrehozás: TYPE táblatípusnév IS TABLE OF {oszloptípus | rekordtípus} INDEX BY BINARY_INTEGER
- az INSERT, UPDATE, FETCH, SELECT utasításokkal kezelhetõ
- gyûjtõtábla metódusok
	EXISTS(n)	- igaz, ha létezik az n-edik elem
	COUNT		- táblában lévõ elemek száma	
	FIRST/LAST	- tábla elsõ/utolsó indexértéke
	NEXT(n)		- a táblában a következõ index értéke
	DELETE(n)	- az n-edik elem törlése

Példa:
	DECLARE
		TYPE tipus IS TABLE OF DEMO.vevo%ROWTYPE
		INDEX BY BINARY_INTEGER;
		valtozo tipus;
		ind BINARY_INTEGER := 1;
	BEGIN
		LOOP
			SELECT *
			INTO valtozo(ind)
			FROM DEMO.vevo
			WHERE partner_id = 20 + ind;
			ind := ind + 1;
		EXIT WHEN ind > 8;
		END LOOP;
		ind := valtozo.FIRST;
		LOOP
			DBMS_OUTPUT.PUT_LINE(valtozo(ind).megnevezes);
			ind := ind + 1;
		EXIT WHEN ind > valtozo.LAST;
		END LOOP;
	END;


Kivételkezelés
--------------

- EXCEPTION WHEN kivétel [OR kivétel ...] utasítások, [WHEN OTHERS utasítások]
- NO_DATA_FOUND: SELECT utasitas nem ad vissza sort
- TOO_MANY_ROWS: egy sort kellett volna visszaadnia egy SELECT-nek, de többet kaptunk 
- INVALID_NUMBER: karakterlánc sikertelen számmá konvertálása

Példa:
	DECLARE
		v_ber DEMO.munkatars.ber%TYPE;
		v_veznev DEMO.munkatars.vezeteknev%TYPE;
		v_kernev DEMO.munkatars.keresztnev%TYPE;
	BEGIN
		v_ber := 200000;
		SELECT vezeteknev, keresztnev
		INTO v_veznev, v_kernev
		FROM DEMO.munkatars
		WHERE ber = v_ber;
		DBMS_OUTPUT.PUT_LINE(v_veznev || ' ' || v_kernev);
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			DBMS_OUTPUT.PUT_LINE('Nincs ilyen fizetés');
		WHEN TOO_MANY_ROWS THEN
			DBMS_OUTPUT.PUT_LINE('Több embernek is ez a fizetése');
	   	WHEN OTHERS THEN
			DBMS_OUTPUT.PUT_LINE('Egyéb hiba');
	END;


- Felhasználói kivételek
	- a DECLARE szakaszban: kivételnév EXCEPTION;
	- végrehajtható szegmensben RAISE utasítással váltható ki;

Példa:
	DECLARE
		nincs_vevo EXCEPTION;
	BEGIN
		DBMS_OUTPUT.PUT_LINE('Ez vegrehajtodik');
		RAISE nincs_vevo;
		DBMS_OUTPUT.PUT_LINE('Ez nem hajtodik vegre');
	EXCEPTION
		WHEN nincs_vevo THEN
			DBMS_OUTPUT.PUT_LINE('Nincs ilyen vevo');
		WHEN OTHERS THEN
			DBMS_OUTPUT.PUT_LINE('Egyéb hiba');
	END;	
