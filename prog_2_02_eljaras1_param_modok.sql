DECLARE

  v_Szam        NUMBER;

  PROCEDURE inp(p_In IN NUMBER) 
  IS
  BEGIN
    DBMS_OUTPUT.PUT_LINE('in:' || p_In);
    /* Az értékadás nem megengedett, 
      az IN módú paraméter konstansként viselkedik a törzsben,
      ezért a következõ utasítás fordítási hibát eredményezne: */
    -- p_In := 0;
  END inp;

  PROCEDURE outp(p_Out OUT NUMBER) 
  IS
  BEGIN
    /* Az OUT módú paraméter értékére lehet hivatkozni.
       Kezdeti értéke azonban NULL. */
    DBMS_OUTPUT.PUT_LINE('out:' || NVL(p_Out, -1)); 
    p_Out := 20;
  END outp;

  PROCEDURE inoutp(p_Inout IN OUT NUMBER) 
  IS
  BEGIN
    /* Az IN OUT módú paraméter értékére lehet hivatkozni.
       Kezdeti értéke az aktuális paraméter értéke lesz. */
    DBMS_OUTPUT.PUT_LINE('inout:' || p_Inout);
    p_Inout := 30;
  END inoutp;

  PROCEDURE outp_kivetel(p_Out IN OUT NUMBER) 
  IS
  BEGIN
    /* Az OUT és az IN OUT módú paraméter értéke csak az alprogram
       sikeres lefutása esetén kerül vissza az aktuális paraméterbe.
       Kezeletlen kivétel esetén nem.
    */
    p_Out := 40;
    DBMS_OUTPUT.PUT_LINE('kivétel elõtt:' || p_Out);
    RAISE VALUE_ERROR;
  END outp_kivetel;

BEGIN
  v_Szam := 10;
  DBMS_OUTPUT.PUT_LINE('1:' || v_Szam);
  inp(v_Szam);
  inp(v_Szam + 1000); -- tetszõleges kifejezés lehet IN módú paraméter
  DBMS_OUTPUT.PUT_LINE('2:' || v_Szam);
  outp(v_Szam);
  /* outp és inoutp paramétere csak változó lehet, ezért 
     a következõ utasítás fordítási hibát eredményezne: */
  -- outp(v_Szam + 1000); 
  DBMS_OUTPUT.PUT_LINE('3:' || v_Szam);
  inoutp(v_Szam);
  /* A következõ utasítás is fordítási hibát eredményezne: */
  -- inoutp(v_Szam + 1000);
  DBMS_OUTPUT.PUT_LINE('4:' || v_Szam);
  outp_kivetel(v_Szam);

EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('kivételkezelõben:' || v_Szam);
END;
/

/*
Eredmény:

1:10
in:10
in:1010
2:10
out:-1
3:20
inout:20
4:30
kivétel elõtt:40
kivételkezelõben:30

A PL/SQL eljárás sikeresen befejezõdött.
*/
