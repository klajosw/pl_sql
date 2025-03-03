DECLARE

  v_Marad       NUMBER;

  /* 
    Megadja, hogy a p_Ugyfel_id azonosítójú ügyfél még
    még hány könyvet kölcsönözhet.
  */
  PROCEDURE marad(
    p_Ugyfel_id     ugyfel.id%TYPE,
    p_Kolcsonozhet  OUT NUMBER
  ) IS
  BEGIN
    SELECT max_konyv - db
      INTO p_Kolcsonozhet
      FROM 
        (SELECT max_konyv FROM ugyfel WHERE id = p_Ugyfel_id), 
        (SELECT COUNT(1) AS db FROM kolcsonzes WHERE kolcsonzo = p_Ugyfel_id);
  END marad;

  /* 
    Megadja, hogy a p_Ugyfel_nev nevû ügyfél
    még hány könyvet kölcsönözhet.
  */
  PROCEDURE marad(
    p_Ugyfel_nev    ugyfel.nev%TYPE,
    p_Kolcsonozhet  OUT NUMBER
  ) IS
    v_Id        ugyfel.id%TYPE;
  BEGIN
    SELECT id 
      INTO v_Id
      FROM ugyfel
      WHERE nev = p_Ugyfel_nev;
    marad(v_Id, p_Kolcsonozhet);
  END marad;

BEGIN
  /* József István (15) */
  marad(15, v_Marad);
  DBMS_OUTPUT.PUT_LINE('1: ' || v_Marad);

  /* Komor Ágnes (30) */
  marad('Komor Ágnes', v_Marad);
  DBMS_OUTPUT.PUT_LINE('2: ' || v_Marad);
END;
/

/*
Eredmény:

1: 0
2: 3

A PL/SQL eljárás sikeresen befejezõdött.
*/  
