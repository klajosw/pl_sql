CREATE TYPE T_Szerzok IS
  VARRAY (10) OF VARCHAR2(50)
/

CREATE TABLE Konyv (
  id         NUMBER,
  ISBN       VARCHAR2(30) NOT NULL,
  Cim        VARCHAR2(100) NOT NULL,
  Kiado      VARCHAR2(100) NOT NULL,
  Kiadasi_ev VARCHAR2(10) NOT NULL,
  Szerzo     T_Szerzok NOT NULL,
  Keszlet    NUMBER NOT NULL,
  Szabad     NUMBER NOT NULL,
  CONSTRAINT konyv_pk PRIMARY KEY (id),
  CONSTRAINT konyv_szabad CHECK (Szabad >= 0)
)
/

CREATE SEQUENCE konyv_seq START WITH 100 INCREMENT BY 5
/

CREATE TYPE T_Tetel IS OBJECT(
       Konyv_id    NUMBER,
       Datum       DATE
)
/      

CREATE TYPE T_Konyvek IS
       TABLE OF T_Tetel
/

CREATE TABLE Ugyfel (
  id                NUMBER,
  Nev               VARCHAR2(100) NOT NULL,
  Anyja_neve        VARCHAR2(50) NOT NULL,
  Lakcim            VARCHAR2(100) NOT NULL,
  Tel_szam          VARCHAR2(20),
  Foglalkozas       VARCHAR2(50),
  Beiratkozas       DATE NOT NULL,
  Max_konyv         NUMBER DEFAULT 10 NOT NULL,
  Konyvek           T_Konyvek DEFAULT T_Konyvek(),
  CONSTRAINT ugyfel_pk PRIMARY KEY (id)
) NESTED TABLE Konyvek STORE AS ugyfel_konyvek
/

CREATE SEQUENCE ugyfel_seq START WITH 100 INCREMENT BY 5
/

CREATE TABLE Kolcsonzes (
  Kolcsonzo         NUMBER NOT NULL,
  Konyv             NUMBER NOT NULL,
  Datum             DATE NOT NULL,
  Hosszabbitva      NUMBER DEFAULT 0 NOT NULL,
  Megjegyzes        VARCHAR2(200),
  CONSTRAINT kolcsonzes_fk1 FOREIGN KEY (Kolcsonzo) 
    REFERENCES Ugyfel(Id),
  CONSTRAINT kolcsonzes_fk2 FOREIGN KEY (Konyv) 
    REFERENCES Konyv(Id)
)
/

CREATE TABLE Kolcsonzes_naplo (
  Konyv_isbn        VARCHAR2(30) NOT NULL,
  Konyv_cim         VARCHAR2(100) NOT NULL,
  Ugyfel_nev        VARCHAR2(100) NOT NULL,
  Ugyfel_anyjaneve  VARCHAR2(50) NOT NULL,
  Elvitte           DATE NOT NULL,
  Visszahozta       DATE NOT NULL,
  Megjegyzes        VARCHAR2(200)
)
/
