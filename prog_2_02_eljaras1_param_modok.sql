DECLARE

  v_Szam        NUMBER;

  PROCEDURE inp(p_In IN NUMBER) 
  IS
  BEGIN
    DBMS_OUTPUT.PUT_LINE('in:' || p_In);
    /* Az �rt�kad�s nem megengedett, 
      az IN m�d� param�ter konstansk�nt viselkedik a t�rzsben,
      ez�rt a k�vetkez� utas�t�s ford�t�si hib�t eredm�nyezne: */
    -- p_In := 0;
  END inp;

  PROCEDURE outp(p_Out OUT NUMBER) 
  IS
  BEGIN
    /* Az OUT m�d� param�ter �rt�k�re lehet hivatkozni.
       Kezdeti �rt�ke azonban NULL. */
    DBMS_OUTPUT.PUT_LINE('out:' || NVL(p_Out, -1)); 
    p_Out := 20;
  END outp;

  PROCEDURE inoutp(p_Inout IN OUT NUMBER) 
  IS
  BEGIN
    /* Az IN OUT m�d� param�ter �rt�k�re lehet hivatkozni.
       Kezdeti �rt�ke az aktu�lis param�ter �rt�ke lesz. */
    DBMS_OUTPUT.PUT_LINE('inout:' || p_Inout);
    p_Inout := 30;
  END inoutp;

  PROCEDURE outp_kivetel(p_Out IN OUT NUMBER) 
  IS
  BEGIN
    /* Az OUT �s az IN OUT m�d� param�ter �rt�ke csak az alprogram
       sikeres lefut�sa eset�n ker�l vissza az aktu�lis param�terbe.
       Kezeletlen kiv�tel eset�n nem.
    */
    p_Out := 40;
    DBMS_OUTPUT.PUT_LINE('kiv�tel el�tt:' || p_Out);
    RAISE VALUE_ERROR;
  END outp_kivetel;

BEGIN
  v_Szam := 10;
  DBMS_OUTPUT.PUT_LINE('1:' || v_Szam);
  inp(v_Szam);
  inp(v_Szam + 1000); -- tetsz�leges kifejez�s lehet IN m�d� param�ter
  DBMS_OUTPUT.PUT_LINE('2:' || v_Szam);
  outp(v_Szam);
  /* outp �s inoutp param�tere csak v�ltoz� lehet, ez�rt 
     a k�vetkez� utas�t�s ford�t�si hib�t eredm�nyezne: */
  -- outp(v_Szam + 1000); 
  DBMS_OUTPUT.PUT_LINE('3:' || v_Szam);
  inoutp(v_Szam);
  /* A k�vetkez� utas�t�s is ford�t�si hib�t eredm�nyezne: */
  -- inoutp(v_Szam + 1000);
  DBMS_OUTPUT.PUT_LINE('4:' || v_Szam);
  outp_kivetel(v_Szam);

EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('kiv�telkezel�ben:' || v_Szam);
END;
/

/*
Eredm�ny:

1:10
in:10
in:1010
2:10
out:-1
3:20
inout:20
4:30
kiv�tel el�tt:40
kiv�telkezel�ben:30

A PL/SQL elj�r�s sikeresen befejez�d�tt.
*/
