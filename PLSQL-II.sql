PL/SQL (Procedural Language/SQL) -II.
=====================================


Kurzorok
--------

- Adatt�bla soronk�nti feldolgoz�s�ra szolg�l
- A mem�ri�ban egy munkater�leten t�rol�dik a kurzorhoz tartoz� t�bla
- Explicit kurzor: a kurzorhoz tartoz� t�bla SELECT utas�t�ssal defini�lt
- Implicit kurzor: minden INSERT, DELETE, UPDATE �s explicit kurzorral nem rendelkez� SELECT utas�t�shoz automatikusan j�n l�tre
- Kurzorf�ggv�nyek:
	SQL%FOUND: a legut�bbi SQL utas�t�s legal�bb egy sort feldolgozott
	SQL%NOTFOUND: a legut�bbi SQL utas�t�s nem dolgozott fel sort
	SQL%ROWCOUNT: a kurzorral �sszesen feldolgozott sorok sz�ma
	SQL%ISOPEN: igaz, ha a kurzor meg van nyitva
	Explicit kurzor eset�n kurzornev%... alak�ak

P�lda implicit kurzorra:

	DECLARE
		v_sor DEMO.vevo%ROWTYPE;
	BEGIN
		SELECT *
		INTO v_sor
		FROM DEMO.vevo
		WHERE partner_id = 21;
		DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT);
	END;


- Explicit kurzor haszn�lata:
	- Deklar�ci�: CURSOR kurzorn�v IS lek�rdez�s 
	- Megnyit�s: OPEN kurzorn�v (megnyit�skor hajt�dik v�gre a lek�rdez�s, a l�trej�v� eredm�nyt�bla nem friss�t�dik!!!)
	- L�ptet�s: FETCH kurzorn�v INTO v�ltoz�k (az aktu�lis sor adatai a v�ltoz�kba ker�lnek �s a kurzor eggyel el�re l�p, ellen�rizni kell, hogy a kurzorhoz tartoz� eredm�nyt�bl�nak van-e sora!!!)
	- Lez�r�s: CLOSE kurzorn�v

P�lda:

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

P�lda:

	DECLARE
		CURSOR nev_es_tel IS
			SELECT vezeteknev, keresztnev, telefon
			FROM DEMO.munkatars
			ORDER BY vezeteknev, keresztnev;
	BEGIN
		FOR m_rek IN nev_es_tel -- a rekordnevet nem kell k�l�n deklar�lni
		LOOP
			DBMS_OUTPUT.PUT_LINE(m_rek.vezeteknev || ' ' || m_rek.keresztnev || ': ' || m_rek.telefon);
		END LOOP;
	END;

	
- Param�terezett kurozorok: CURSOR kurzorn�v (param�tern�v adatt�pus, ..., param�tern�v adatt�pus) IS alk�rd�s;


- T�bla m�dos�t�sa kurzorral, ROWID

P�lda:
	ACCEPT partner_azon PROMPT 'K�rem adja meg a partner azonos�t�t: '
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


- T�bla m�dos�t�sa kurzorral, FOR UPDATE, CURRENT OF
	- NOWAIT: Ha egy m�sik tranzakci� z�rolta a k�r�d�ses sort, akkor hibajelent�ssel tov�bb fut

P�lda:
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

- N�vvel ell�tott �s param�terezhet� blokk
- Deklar�ci�juk a f�program DECLARE szegmens v�g�n
- Elj�r�sok: PROCEDURE n�v [(param�terek)] IS lok�lis deklar�ci�k BEGIN utas�t�sok END [n�v];, IN, OUT, IN OUT

P�lda:

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


- F�ggv�nyek: FUNCTION n�v [(param�terek)] RETURN adatt�pus IS lok�lis deklar�ci�k BEGIN utas�t�sok END [n�v];

P�lda:

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


Adatb�zis-objektumk�nt t�rolt alprogram
---------------------------------------

- deklar�ci� elej�re CREATE
- alap�rtelmez�s IN t�pusu param�terekhez: param�tern�v t�pus DEFAULT �rt�k, param�tert csak a lista v�g�r�l lehet elhagyni
- t�rolt elj�r�s PL/SQL blokkb�l futtathat�, vagy SQL*Plus k�rnyezetben az EXECUTE paranccsal 

P�lda:

	PROCEDURE nyomtat(szoveg IN VARCHAR2 DEFAULT 'empty')

	FUNCTION min_ber (ber IN NUMBER DEFAULT 0) RETURN BOOLEAN

