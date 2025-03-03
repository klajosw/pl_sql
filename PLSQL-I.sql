PL/SQL (Procedural Language/SQL) - I.
=====================================

Alapok
------

- utas�t�st ; z�rja le
- PL/SQL blokk lez�r�sa: /
- kis- �s nagybet� egyen�rt�k� (az utas�t�sokban a kulcsszavakat szoktuk nagybat�vel �rni, de nem k�telz�)
- comment REM vagy --, t�bbsoros /* */
- haszn�lat el�tt deklar�lni kell a v�ltoz�kat, azonos�t�kat, elj�r�sokat
- ** hatv�nyoz�s, != nem egyenl�, || karakterl�nc �sszef�z�s
- egy PL/SQL program egy vagy t�bb blokkb�l �ll, a blokkok egym�sba �gyazhat�k

- blokk fel�p�t�se
	DECLARE
	BEGIN
	EXCEPTION
	END;

P�lda:
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
-- . hat�s�ra befejezodik a PL/SQL blokk v�ge, de nem fut le automatikusan, / hat�s�ra viszont igen

V�ltoz�k deklar�ci�ja: v�ltoz�n�v [CONSTANT] adatt�pus [NOT NULL] [DEFAULT �rt�k]
---------------------------------------------------------------------------------

P�lda:
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

- haszn�lat�t a SET SERVEROUTPUT ON SQL*Plus paranccsal enged�lyezni kell
- PUT: ugyanabba a sorba �r t�bb outputot
- NEW_LINE: sor v�g�t jelzi 
- PUT_LINE: minden outputot k�l�n sorba �r

P�lda:
	SET SERVEROUTPUT ON
	ACCEPT nev PROMPT 'Kerem addja meg a nev�t: '  
	DECLARE 
		szoveg varchar2(50);
	BEGIN
		szoveg := CONCAT('&nev',' sikeresen v�grehajtotta a programot!');
		DBMS_OUTPUT.PUT_LINE (szoveg);
	END;


V�ltoz� �rt�kad�s a SELECT... INTO... utas�t�ssal
-------------------------------------------------

P�lda:
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


Rekordt�pus, v�ltoz� deklar�l�s adatt�bla t�pusokb�l
----------------------------------------------------

- %TYPE, %ROWTYPE

P�lda:
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


P�lda:
	DECLARE
		v_sor DEMO.vevo%ROWTYPE;
	BEGIN
		SELECT * INTO v_sor 
		FROM DEMO.vevo 
		WHERE partner_id = 21;
		DBMS_OUTPUT.PUT_LINE(v_sor.MEGNEVEZES);
	END; 



- TYPE rekordt�pusn�v IS RECORD (mez�n�v t�pus,..., mez�n�v t�pus)

P�lda:
	DECLARE
		TYPE dolgozo_rekord IS RECORD
		   (adoszam INTEGER, nev CHAR(30), lakcim VARCHAR2(50));
		egy_dolgozo dolgozo_rekord;
	BEGIN
		egy_dolgozo.nev := 'Kovacs';
	END;


Vez�rl�si szerkezetek
---------------------

- IF felt�tel THEN, ELSIF felt�tel THEN, ELSE, END IF;

P�lda:
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

P�lda:
	CASE num
   		WHEN 1 THEN dbms_output.put_line('Egy');
			.
			.
			.
   		WHEN 9 THEN dbms_output.put_line('Kilenc');
   		ELSE dbms_output.put_line('Nem egyjegyu');
 	END CASE;	


- LOOP, [EXIT;], [EXIT WHEN felt�tel;], END LOOP;

P�lda:
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

	
- FOR ciklusv�ltoz� IN [REVERSE] als�hat�r .. felsohat�r LOOP, END LOOP;

P�lda:
	FOR num IN 1..500 LOOP
	   INSERT INTO roots VALUES (num, SQRT(num));
	END LOOP;


- WHILE felt�tel, LOOP, END LOOP;

P�lda:
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


Gy�jt�t�bl�k kezel�se
---------------------

- r�szben listaszer�en, r�szben t�mbszer�en kezelhet� adatstrukt�ra
- oszlopai: adat (oszlop vagy rekord t�pus� lehet), index (BINARY INTEGER)
- m�rete nem korl�tozott
- t�mbk�nt indexelhet�, ahol az index NEGAT�V is lehet: adat(index)
- �j sorokkal b�v�thet� �s t�r�lhet� --> h�zagok lehetnek benne

- l�trehoz�s: TYPE t�blat�pusn�v IS TABLE OF {oszlopt�pus | rekordt�pus} INDEX BY BINARY_INTEGER
- az INSERT, UPDATE, FETCH, SELECT utas�t�sokkal kezelhet�
- gy�jt�t�bla met�dusok
	EXISTS(n)	- igaz, ha l�tezik az n-edik elem
	COUNT		- t�bl�ban l�v� elemek sz�ma	
	FIRST/LAST	- t�bla els�/utols� index�rt�ke
	NEXT(n)		- a t�bl�ban a k�vetkez� index �rt�ke
	DELETE(n)	- az n-edik elem t�rl�se

P�lda:
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


Kiv�telkezel�s
--------------

- EXCEPTION WHEN kiv�tel [OR kiv�tel ...] utas�t�sok, [WHEN OTHERS utas�t�sok]
- NO_DATA_FOUND: SELECT utasitas nem ad vissza sort
- TOO_MANY_ROWS: egy sort kellett volna visszaadnia egy SELECT-nek, de t�bbet kaptunk 
- INVALID_NUMBER: karakterl�nc sikertelen sz�mm� konvert�l�sa

P�lda:
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
			DBMS_OUTPUT.PUT_LINE('Nincs ilyen fizet�s');
		WHEN TOO_MANY_ROWS THEN
			DBMS_OUTPUT.PUT_LINE('T�bb embernek is ez a fizet�se');
	   	WHEN OTHERS THEN
			DBMS_OUTPUT.PUT_LINE('Egy�b hiba');
	END;


- Felhaszn�l�i kiv�telek
	- a DECLARE szakaszban: kiv�teln�v EXCEPTION;
	- v�grehajthat� szegmensben RAISE utas�t�ssal v�lthat� ki;

P�lda:
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
			DBMS_OUTPUT.PUT_LINE('Egy�b hiba');
	END;	
