DECLARE
  v_Arucikk        T_Arucikk;
  v_Kepeslap       T_Kepeslap;
  v_Toll           T_Toll;
  v_Terulet        NUMBER;
BEGIN
  v_Toll := NEW T_Toll('Goly�s toll', 150, 55, 'k�k', 8, 0.95);
  DBMS_OUTPUT.PUT_LINE('Tollak mennyis�ge: ' || v_Toll.mennyiseg);
  -- Megv�ltoztatjuk az �rat:
  v_Toll.ar := 200;

  v_Kepeslap := NEW T_Kepeslap('Boldog sz�linapot lap', 
                               80, 200, NEW T_Teglalap(10, 15));

  -- Hivatkoz�s kollekci� attrib�tum�ra
  v_Terulet := v_Kepeslap.meret.terulet;
  DBMS_OUTPUT.PUT_LINE('Egy k�peslap ter�lete: ' || v_Terulet);

  -- Konstruktor kifejez�sben
  DBMS_OUTPUT.PUT_LINE('Egy l�gb�l kapott t�tel �ssz�rt�k�nek a fele: '
    || (T_Kepeslap('�dv�zlet Debrecenb�l', 
                    120, 50, NEW T_Teglalap(15, 10)).osszertek / 2) );
END;
/
/*
Tollak mennyis�ge: 55
Egy k�peslap ter�lete: 150
Egy l�gb�l kapott t�tel �ssz�rt�k�nek a fele: 3000

A PL/SQL elj�r�s sikeresen befejez�d�tt.
*/
