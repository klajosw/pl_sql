/*
  Letiltjuk azt a triggert, amelyik lehetõvé teszi
  az ugyfel_kolcsonzes nézet konyvek oszlopának módosítását.
*/
ALTER TRIGGER tr_ugyfel_kolcsonzes_del DISABLE;

DELETE FROM TABLE(SELECT konyvek FROM ugyfel_kolcsonzes
                    WHERE id = 15)
  WHERE konyv_id = 45;
/*
DELETE FROM TABLE(SELECT konyvek FROM ugyfel_kolcsonzes
                                      *
Hiba a(z) 1. sorban:
ORA-25015: ezen a beágyazott táblanézet oszlopon nem hajtható végre DML
*/

-- Újra engedélyezzük a triggert.
ALTER TRIGGER tr_ugyfel_kolcsonzes_del ENABLE;

-- Explicit módon újrafordítjuk a régi beállításokkal
ALTER TRIGGER tr_ugyfel_kolcsonzes_del COMPILE REUSE SETTINGS;

-- Át is nevezhetjük:
ALTER TRIGGER tr_ugyfel_kolcsonzes_del RENAME TO tr_ugyf_kolcs_del;
