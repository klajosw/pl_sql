/*
  Az egyes mûveletek mögött láthatók az eredmények. 
  Ezek ellenõrzéséhez az SQL*Developer vagy más IDE debuggerét javasoljuk.
  Ehhez szükséges a DEBUG CONNECT SESSION jogosultság

  Megoldás lenne még az eredmények köztes kiíratása is.
*/

-- Néhány példához adatbázisban kell létrehozni típust
CREATE TYPE T_Multiset_ab IS 
  TABLE OF CHAR(1)
/
CREATE TYPE T_Multiset_multiset_ab IS 
  TABLE OF T_Multiset_ab;
/
ALTER SESSION SET plsql_debug=true;

CREATE OR REPLACE PROCEDURE proc_multiset_op_fv_teszt IS

  TYPE t_multiset_plsql IS TABLE OF CHAR(1);

  -- t_multiset változók - fõ operandusok
  v_Ures        t_multiset_plsql := t_multiset_plsql();
  v_abc         t_multiset_plsql := t_multiset_plsql('a','b','c');
  v_abca        t_multiset_plsql := t_multiset_plsql('a','b','c','a');
  v_abc_nullal  t_multiset_plsql := t_multiset_plsql('a','b','c',NULL);
  v_aaabbcdee   t_multiset_plsql :=
      t_multiset_plsql('a','a','a','b','b','c','d','e','e');
  v_ccdd        t_multiset_plsql := t_multiset_plsql('c','c','d','d');
  
  v_abc_ab      T_Multiset_ab := T_Multiset_ab('a','b','c');

  -- eredménytárolók
  b  BOOLEAN;
  m  t_multiset_plsql;
  i  BINARY_INTEGER;
  mm T_Multiset_multiset_ab;

  -- segédeljárás: az adatbázisbeli típusú paraméter tartalmát 
  -- a lokális típusú paraméterbe másolja, mert a debugger
  -- csak a lokális típusú változókba tud belenézni
  PROCEDURE convert_to_plsql(
    p_From               T_Multiset_ab,
    p_To   IN OUT NOCOPY t_multiset_plsql
  ) IS
   j BINARY_INTEGER;
  BEGIN
    p_To.DELETE;
    p_To.EXTEND(p_From.COUNT);
    FOR i IN 1..p_From.COUNT 
    LOOP
      p_To(i) := p_From(i);
    END LOOP;
  END convert_to_plsql;

BEGIN
  /* Logikai kifejezések */

  -- IS [NOT] A SET
  b := v_abc  IS A SET; -- TRUE;
  b := v_abca IS A SET; -- FALSE;

  -- IS [NOT] EMPTY
  b := v_abc  IS NOT EMPTY; -- TRUE;
  b := v_Ures IS NOT EMPTY; -- FALSE;

  -- MEMBER
  b := 'a'  MEMBER v_abc; -- TRUE;
  b := 'z'  MEMBER v_abc; -- FALSE;
  b := NULL MEMBER v_abc; -- NULL;
  b := 'a'  MEMBER v_abc_nullal; -- TRUE;
  b := 'z'  MEMBER v_abc_nullal; -- NULL;
  b := NULL MEMBER v_abc_nullal; -- NULL;

  -- SUBMULTISET
  b := v_Ures SUBMULTISET v_abc;  -- TRUE;
  b := v_abc  SUBMULTISET v_abca; -- TRUE;
  b := v_abca SUBMULTISET v_abc;  -- FALSE;

  /* Kollekció kifejezések */

  -- MULTISET {EXCEPT|INTERSECT|UNION} [{ALL|DISTINCT}] operátorok
  m := v_abca      MULTISET EXCEPT v_ccdd;          -- {a,b,a}
  m := v_aaabbcdee MULTISET EXCEPT v_abca;          -- {a,b,d,e,e}
  m := v_aaabbcdee MULTISET EXCEPT DISTINCT v_abca; -- {d,e}
  m := v_aaabbcdee MULTISET INTERSECT v_abca;          -- {a,a,b,c}
  m := v_aaabbcdee MULTISET INTERSECT DISTINCT v_abca; -- {a,b,c}
  m := v_abca MULTISET UNION v_ccdd;           -- {a,b,c,a,c,c,d,d}
  m := v_abca MULTISET UNION DISTINCT v_ccdd;  -- {a,b,c,d}

  /* PL/SQL-ben közvetlenül is alkalmazható kollekció függvények */

  -- CARDINALITY, vesd össze a COUNT metódusssal
  i := CARDINALITY(v_abc);  -- 3
  i := v_abc.COUNT;         -- 3
  i := CARDINALITY(v_Ures); -- 0
  i := v_Ures.COUNT;        -- 0

  -- SET
  m := SET(v_abca);         -- {a,b,c}
  b := v_abc = SET(v_abca); -- TRUE;

  /* PL/SQL-ben közvetlenül nem alkalmazható kollekció függvények */
  
  -- COLLECT
  FOR r IN (
  SELECT grp, CAST(COLLECT(col) AS T_Multiset_ab) collected
    FROM (
          SELECT 1 grp, 'a' col FROM dual UNION ALL
          SELECT 1 grp, 'b' col FROM dual UNION ALL
          SELECT 2 grp, 'c' col FROM dual
         )
    GROUP BY grp
  ) LOOP
    i := r.grp;                       -- 1      majd 2
    -- debuggerrel tudjuk vizsgálni m értékét a konverzió után
    convert_to_plsql(r.collected, m); -- {a,b}  majd {c}
  END LOOP;  
  
  -- POWERMULTISET
  SELECT CAST(POWERMULTISET(v_abc_ab) AS T_Multiset_multiset_ab)
    INTO mm
    FROM dual;
  -- mm : { {a}, {b}, {a,b}, {c}, {a,c}, {b,c}, {a,b,c} }
  i := mm.COUNT; -- 7
  convert_to_plsql(mm(1), m); -- {a}
  convert_to_plsql(mm(2), m); -- {b}
  convert_to_plsql(mm(3), m); -- {a,b}
  convert_to_plsql(mm(4), m); -- {c}
  convert_to_plsql(mm(5), m); -- {a,c}
  convert_to_plsql(mm(6), m); -- {b,c}
  convert_to_plsql(mm(7), m); -- {a,b,c}
  
  -- POWERMULTISET_BY_CARDINALITY
  SELECT CAST(POWERMULTISET_BY_CARDINALITY(v_abc_ab, 2)
              AS T_Multiset_multiset_ab)
    INTO mm
    FROM dual;
  -- mm : { {a,b}, {a,c}, {b,c} }
  i := mm.COUNT; -- 3
  convert_to_plsql(mm(1), m); -- {a,b}
  convert_to_plsql(mm(2), m); -- {a,c}
  convert_to_plsql(mm(3), m); -- {b,c}
  
END proc_multiset_op_fv_teszt;
/
show errors
