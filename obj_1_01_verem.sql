CREATE OR REPLACE TYPE T_Egesz_szamok IS TABLE OF INTEGER;
/

CREATE OR REPLACE TYPE T_Verem AS OBJECT ( 
  max_meret INTEGER, 
  top       INTEGER,
  elemek    T_Egesz_szamok,

  -- Az alapértelmezett konstruktort elfedjük
  CONSTRUCTOR FUNCTION T_Verem(
    max_meret INTEGER,
    top INTEGER,
    elemek T_Egesz_szamok
  ) RETURN SELF AS RESULT,

  -- Saját konstruktor használata
  CONSTRUCTOR FUNCTION T_Verem(
    p_Max_meret INTEGER
  ) RETURN SELF AS RESULT,

  -- Metódusok
  MEMBER FUNCTION tele RETURN BOOLEAN,
  MEMBER FUNCTION ures RETURN BOOLEAN,
  MEMBER PROCEDURE push (n IN INTEGER),
  MEMBER PROCEDURE pop (n OUT INTEGER)
);
/
show errors

CREATE OR REPLACE TYPE BODY T_Verem AS 

  -- Kivétel dobásával meggátoljuk az alapértelmezett konstruktor hívását
  CONSTRUCTOR FUNCTION T_Verem(
    max_meret INTEGER,
    top INTEGER,
    elemek T_Egesz_szamok
  ) RETURN SELF AS RESULT
  IS
  BEGIN
    RAISE_APPLICATION_ERROR(-20001, 'Nem használható ez a konstruktor. '
      || 'Ajánlott konstruktor: T_Verem(p_Max_meret)');
  END T_Verem;

  CONSTRUCTOR FUNCTION T_Verem(
    p_Max_meret INTEGER
  ) RETURN SELF AS RESULT
  IS
  BEGIN
    max_meret := p_Max_meret;
    top := 0;
    /* Inicializáljuk az elemek tömböt a maximális elemszámra. */
    max_meret := p_Max_meret;       
    elemek    := NEW T_Egesz_szamok(); -- Ajánlott a NEW használata
    elemek.EXTEND(max_meret); -- Elõre lefoglaljuk a helyet az elemeknek
    RETURN;
  END T_Verem;

  MEMBER FUNCTION tele RETURN BOOLEAN IS 
  BEGIN
    -- Igazat adunk vissza, ha tele van a verem
    RETURN (top = max_meret);
  END tele;

  MEMBER FUNCTION ures RETURN BOOLEAN IS 
  BEGIN
    -- Igazat adunk vissza, ha üres a verem
    RETURN (top = 0);
  END ures;

  MEMBER PROCEDURE push(n IN INTEGER) IS 
  BEGIN
    IF NOT tele THEN
      top := top + 1;  -- írunk a verembe
      elemek(top) := n;
    ELSE  -- a verem megtelt
      RAISE_APPLICATION_ERROR(-20101, 'A verem már megtelt');
    END IF;
  END push;

  MEMBER PROCEDURE pop (n OUT INTEGER) IS
  BEGIN
    IF NOT ures THEN
      n := elemek(top);
      top := top - 1;  -- olvasunk a verembõl
    ELSE  -- a verem üres
      RAISE_APPLICATION_ERROR(-20102, 'A verem üres');
    END IF;
  END pop;
END;
/
show errors

/* Használata */
DECLARE
  v_Verem   T_Verem;
  i         INTEGER;
BEGIN
  -- Az alapértelmezett konstruktor már nem használható itt
  BEGIN
    v_Verem := NEW T_Verem(5, 0, NULL);
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Kivétel - 1: ' || SQLERRM);
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
      DBMS_OUTPUT.PUT_LINE('Kivétel - 2: ' || SQLERRM);
  END;

  BEGIN
    LOOP
      v_Verem.pop(i);
      DBMS_OUTPUT.PUT_LINE(i);
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Kivétel - 3: ' || SQLERRM);
  END;
END;
/

/*
Kivétel - 1: ORA-20001: Nem használható ez a konstruktor. Ajánlott konstruktor: T_Verem(p_Max_meret)
Kivétel - 2: ORA-20101: A verem már megtelt
5
4
3
2
1
Kivétel - 3: ORA-20102: A verem üres

A PL/SQL eljárás sikeresen befejezõdött.
*/
