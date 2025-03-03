DECLARE
  v_Arucikk        T_Arucikk;
  v_Kepeslap       T_Kepeslap;
  v_Toll           T_Toll;
  v_Terulet        NUMBER;
BEGIN
  v_Toll := NEW T_Toll('Golyós toll', 150, 55, 'kék', 8, 0.95);
  DBMS_OUTPUT.PUT_LINE('Tollak mennyisége: ' || v_Toll.mennyiseg);
  -- Megváltoztatjuk az árat:
  v_Toll.ar := 200;

  v_Kepeslap := NEW T_Kepeslap('Boldog szülinapot lap', 
                               80, 200, NEW T_Teglalap(10, 15));

  -- Hivatkozás kollekció attribútumára
  v_Terulet := v_Kepeslap.meret.terulet;
  DBMS_OUTPUT.PUT_LINE('Egy képeslap területe: ' || v_Terulet);

  -- Konstruktor kifejezésben
  DBMS_OUTPUT.PUT_LINE('Egy légbõl kapott tétel összértékének a fele: '
    || (T_Kepeslap('Üdvözlet Debrecenbõl', 
                    120, 50, NEW T_Teglalap(15, 10)).osszertek / 2) );
END;
/
/*
Tollak mennyisége: 55
Egy képeslap területe: 150
Egy légbõl kapott tétel összértékének a fele: 3000

A PL/SQL eljárás sikeresen befejezõdött.
*/
