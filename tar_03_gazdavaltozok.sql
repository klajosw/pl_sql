/* 
  Gazdaváltozók az SQL*Plus futtató környezetben.
*/
VARIABLE v_Osszes       NUMBER;
VARIABLE v_Aktiv        NUMBER;

/*
  Tárolt alprogramok hívása
*/
CALL osszes_kolcsonzo() INTO :v_Osszes;
CALL aktiv_kolcsonzo() INTO :v_Aktiv;

/*
  Arány számolása és kiíratása
*/

PROMPT A jelenleg aktív ügyfelek aránya a kölcsönzõk körében:
SELECT TO_CHAR(:v_Aktiv*100/:v_Osszes, '999.99') || '%' AS "Arány" FROM dual;

