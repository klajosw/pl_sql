CREATE OR REPLACE TYPE T_Egesz_szamok IS TABLE OF INTEGER;
/

CREATE OR REPLACE TYPE T_Verem AS OBJECT ( 
  max_meret INTEGER, 
  top       INTEGER,
  elemek    T_Egesz_szamok,

  -- Az alap�rtelmezett konstruktort elfedj�k
  CONSTRUCTOR FUNCTION T_Verem(
    max_meret INTEGER,
    top INTEGER,
    elemek T_Egesz_szamok
  ) RETURN SELF AS RESULT,

  -- Saj�t konstruktor haszn�lata
  CONSTRUCTOR FUNCTION T_Verem(
    p_Max_meret INTEGER
  ) RETURN SELF AS RESULT,

  -- Met�dusok
  MEMBER FUNCTION tele RETURN BOOLEAN,
  MEMBER FUNCTION ures RETURN BOOLEAN,
  MEMBER PROCEDURE push (n IN INTEGER),
  MEMBER PROCEDURE pop (n OUT INTEGER)
);
/
show errors

CREATE OR REPLACE TYPE BODY T_Verem AS 

  -- Kiv�tel dob�s�val megg�toljuk az alap�rtelmezett konstruktor h�v�s�t
  CONSTRUCTOR FUNCTION T_Verem(
    max_meret INTEGER,
    top INTEGER,
    elemek T_Egesz_szamok
  ) RETURN SELF AS RESULT
  IS
  BEGIN
    RAISE_APPLICATION_ERROR(-20001, 'Nem haszn�lhat� ez a konstruktor. '
      || 'Aj�nlott konstruktor: T_Verem(p_Max_meret)');
  END T_Verem;

  CONSTRUCTOR FUNCTION T_Verem(
    p_Max_meret INTEGER
  ) RETURN SELF AS RESULT
  IS
  BEGIN
    max_meret := p_Max_meret;
    top := 0;
    /* Inicializ�ljuk az elemek t�mb�t a maxim�lis elemsz�mra. */
    max_meret := p_Max_meret;       
    elemek    := NEW T_Egesz_szamok(); -- Aj�nlott a NEW haszn�lata
    elemek.EXTEND(max_meret); -- El�re lefoglaljuk a helyet az elemeknek
    RETURN;
  END T_Verem;

  MEMBER FUNCTION tele RETURN BOOLEAN IS 
  BEGIN
    -- Igazat adunk vissza, ha tele van a verem
    RETURN (top = max_meret);
  END tele;

  MEMBER FUNCTION ures RETURN BOOLEAN IS 
  BEGIN
    -- Igazat adunk vissza, ha �res a verem
    RETURN (top = 0);
  END ures;

  MEMBER PROCEDURE push(n IN INTEGER) IS 
  BEGIN
    IF NOT tele THEN
      top := top + 1;  -- �runk a verembe
      elemek(top) := n;
    ELSE  -- a verem megtelt
      RAISE_APPLICATION_ERROR(-20101, 'A verem m�r megtelt');
    END IF;
  END push;

  MEMBER PROCEDURE pop (n OUT INTEGER) IS
  BEGIN
    IF NOT ures THEN
      n := elemek(top);
      top := top - 1;  -- olvasunk a veremb�l
    ELSE  -- a verem �res
      RAISE_APPLICATION_ERROR(-20102, 'A verem �res');
    END IF;
  END pop;
END;
/
show errors

/* Haszn�lata */
DECLARE
  v_Verem   T_Verem;
  i         INTEGER;
BEGIN
  -- Az alap�rtelmezett konstruktor m�r nem haszn�lhat� itt
  BEGIN
    v_Verem := NEW T_Verem(5, 0, NULL);
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Kiv�tel - 1: ' || SQLERRM);
  END;

  v_Verem := NEW T_Verem(p_Max_meret => 5); 
  i := 1;
  BEGIN
    LOOP
      v_Verem.push(i);
      i := i + 1;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Kiv�tel - 2: ' || SQLERRM);
  END;

  BEGIN
    LOOP
      v_Verem.pop(i);
      DBMS_OUTPUT.PUT_LINE(i);
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Kiv�tel - 3: ' || SQLERRM);
  END;
END;
/

/*
Kiv�tel - 1: ORA-20001: Nem haszn�lhat� ez a konstruktor. Aj�nlott konstruktor: T_Verem(p_Max_meret)
Kiv�tel - 2: ORA-20101: A verem m�r megtelt
5
4
3
2
1
Kiv�tel - 3: ORA-20102: A verem �res

A PL/SQL elj�r�s sikeresen befejez�d�tt.
*/
