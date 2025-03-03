DECLARE

  v_Marad       NUMBER;

  /* 
    Megadja, hogy a p_Ugyfel_id azonos�t�j� �gyf�l m�g
    m�g h�ny k�nyvet k�lcs�n�zhet.
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
    Megadja, hogy a p_Ugyfel_nev nev� �gyf�l
    m�g h�ny k�nyvet k�lcs�n�zhet.
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
  /* J�zsef Istv�n (15) */
  marad(15, v_Marad);
  DBMS_OUTPUT.PUT_LINE('1: ' || v_Marad);

  /* Komor �gnes (30) */
  marad('Komor �gnes', v_Marad);
  DBMS_OUTPUT.PUT_LINE('2: ' || v_Marad);
END;
/

/*
Eredm�ny:

1: 0
2: 3

A PL/SQL elj�r�s sikeresen befejez�d�tt.
*/  
