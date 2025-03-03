/* 
  Gazdav�ltoz�k az SQL*Plus futtat� k�rnyezetben.
*/
VARIABLE v_Osszes       NUMBER;
VARIABLE v_Aktiv        NUMBER;

/*
  T�rolt alprogramok h�v�sa
*/
CALL osszes_kolcsonzo() INTO :v_Osszes;
CALL aktiv_kolcsonzo() INTO :v_Aktiv;

/*
  Ar�ny sz�mol�sa �s ki�rat�sa
*/

PROMPT A jelenleg akt�v �gyfelek ar�nya a k�lcs�nz�k k�r�ben:
SELECT TO_CHAR(:v_Aktiv*100/:v_Osszes, '999.99') || '%' AS "Ar�ny" FROM dual;

