PL/SQL (Procedural Language/SQL) -II.
=====================================


Kurzorok
--------

- Adattábla soronkénti feldolgozására szolgál
- A memóriában egy munkaterületen tárolódik a kurzorhoz tartozó tábla
- Explicit kurzor: a kurzorhoz tartozó tábla SELECT utasítással definiált
- Implicit kurzor: minden INSERT, DELETE, UPDATE és explicit kurzorral nem rendelkezõ SELECT utasításhoz automatikusan jön létre
- Kurzorfüggvények:
	SQL%FOUND: a legutóbbi SQL utasítás legalább egy sort feldolgozott
	SQL%NOTFOUND: a legutóbbi SQL utasítás nem dolgozott fel sort
	SQL%ROWCOUNT: a kurzorral összesen feldolgozott sorok száma
	SQL%ISOPEN: igaz, ha a kurzor meg van nyitva
	Explicit kurzor esetén kurzornev%... alakúak

Példa implicit kurzorra:

	DECLARE
		v_sor DEMO.vevo%ROWTYPE;
	BEGIN
		SELECT *
		INTO v_sor
		FROM DEMO.vevo
		WHERE partner_id = 21;
		DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT);
	END;


- Explicit kurzor használata:
	- Deklaráció: CURSOR kurzornév IS lekérdezés 
	- Megnyitás: OPEN kurzornév (megnyitáskor hajtódik végre a lekérdezés, a létrejövõ eredménytábla nem frissítõdik!!!)
	- Léptetés: FETCH kurzornév INTO változók (az aktuális sor adatai a változókba kerülnek és a kurzor eggyel elõre lép, ellenõrizni kell, hogy a kurzorhoz tartozó eredménytáblának van-e sora!!!)
	- Lezárás: CLOSE kurzornév

Példa:

	DECLARE
		v_veznev DEMO.munkatars.vezeteknev%TYPE;
		v_kernev DEMO.munkatars.keresztnev%TYPE;
		v_tel DEMO.munkatars.telefon%TYPE;
		CURSOR nev_es_tel IS
			SELECT vezeteknev, keresztnev, telefon
			FROM DEMO.munkatars
			ORDER BY vezeteknev, keresztnev;
	BEGIN
		OPEN nev_es_tel;
		LOOP
			FETCH nev_es_tel
			INTO v_veznev, v_kernev, v_tel;
			EXIT WHEN nev_es_tel%NOTFOUND;
			DBMS_OUTPUT.PUT_LINE(v_veznev || ' ' || v_kernev || ': ' || v_tel);
		END LOOP;
		CLOSE nev_es_tel;
	END;


- Explicit kurzor FOR ciklusban

Példa:

	DECLARE
		CURSOR nev_es_tel IS
			SELECT vezeteknev, keresztnev, telefon
			FROM DEMO.munkatars
			ORDER BY vezeteknev, keresztnev;
	BEGIN
		FOR m_rek IN nev_es_tel -- a rekordnevet nem kell külön deklarálni
		LOOP
			DBMS_OUTPUT.PUT_LINE(m_rek.vezeteknev || ' ' || m_rek.keresztnev || ': ' || m_rek.telefon);
		END LOOP;
	END;

	
- Paraméterezett kurozorok: CURSOR kurzornév (paraméternév adattípus, ..., paraméternév adattípus) IS alkérdés;


- Tábla módosítása kurzorral, ROWID

Példa:
	ACCEPT partner_azon PROMPT 'Kérem adja meg a partner azonosítót: '
	DECLARE
		row_id ROWID;
		id DEMO.vevo.partner_id%TYPE;
	BEGIN
		SELECT ROWID INTO row_id
		FROM DEMO.vevo
		WHERE partner_id = '&partner_azon';
		UPDATE DEMO.vevo
		SET kiallt_szamlak_db = kiallt_szamlak_db + 1
		WHERE ROWID = row_id;
		DBMS_OUTPUT.PUT_LINE(row_id);
	END;


- Tábla módosítása kurzorral, FOR UPDATE, CURRENT OF
	- NOWAIT: Ha egy másik tranzakció zárolta a kérédéses sort, akkor hibajelentéssel tovább fut

Példa:
	DECLARE
		CURSOR partner_update(p_azon CHAR) IS
		SELECT kiallt_szamlak_db
		FROM DEMO.vevo
		WHERE partner_id = p_azon
		FOR UPDATE OF kiallt_szamlak_db NOWAIT;
		darab DEMO.vevo.kiallt_szamlak_db%TYPE;
	BEGIN
		OPEN partner_update('&partner_azon');
		FETCH partner_update
			INTO darab;
		UPDATE DEMO.vevo
		SET kiallt_szamlak_db = darab + 1
		WHERE CURRENT OF partner_update;
	END;
	
	
Alprogramok
-----------

- Névvel ellátott és paraméterezhetõ blokk
- Deklarációjuk a fõprogram DECLARE szegmens végén
- Eljárások: PROCEDURE név [(paraméterek)] IS lokális deklarációk BEGIN utasítások END [név];, IN, OUT, IN OUT

Példa:

	DECLARE
		v_megnev DEMO.vevo.megnevezes%TYPE;
		PROCEDURE nyomtat(szoveg IN VARCHAR2)
		IS
		BEGIN
			DBMS_OUTPUT.PUT_LINE(szoveg);
		END;
	BEGIN
		SELECT megnevezes
		INTO v_megnev
		FROM DEMO.vevo
		WHERE partner_id = 22;
		nyomtat(v_megnev);
	END;


- Függvények: FUNCTION név [(paraméterek)] RETURN adattípus IS lokális deklarációk BEGIN utasítások END [név];

Példa:

	DECLARE
		v_partnerid DEMO.munkatars.partner_id%TYPE;
		v_ber DEMO.munkatars.ber%TYPE;
		FUNCTION min_ber (ber IN NUMBER) RETURN BOOLEAN
		IS
	        	tmp_ber DEMO.munkatars.ber%TYPE;
		BEGIN
	        	SELECT MIN(ber)
	        	INTO tmp_ber
	        	FROM DEMO.munkatars;
	        	RETURN (tmp_ber = ber);
		END min_ber;
	BEGIN
	 	SELECT MIN(partner_id)
		INTO v_partnerid
		FROM DEMO.munkatars;
		LOOP
	        	SELECT ber
	        	INTO v_ber
	        	FROM DEMO.munkatars
	        	WHERE partner_id = v_partnerid;
	        	v_partnerid := v_partnerid + 1;
		EXIT WHEN min_ber(v_ber);
		END LOOP;
		DBMS_OUTPUT.PUT_LINE('A minimal ber: ' || v_ber);
	END;


Adatbázis-objektumként tárolt alprogram
---------------------------------------

- deklaráció elejére CREATE
- alapértelmezés IN típusu paraméterekhez: paraméternév típus DEFAULT érték, paramétert csak a lista végérõl lehet elhagyni
- tárolt eljárás PL/SQL blokkból futtatható, vagy SQL*Plus környezetben az EXECUTE paranccsal 

Példa:

	PROCEDURE nyomtat(szoveg IN VARCHAR2 DEFAULT 'empty')

	FUNCTION min_ber (ber IN NUMBER DEFAULT 0) RETURN BOOLEAN

