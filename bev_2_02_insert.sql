/*
  Konyv:

  id         NUMBER PRIMARY KEY,
  ISBN       VARCHAR2(30) NOT NULL,
  Cim        VARCHAR2(100) NOT NULL,
  Kiado      VARCHAR2(100) NOT NULL,
  Kiadasi_ev VARCHAR2(10) NOT NULL,
  Szerzo     T_Szerzok NOT NULL,
  Keszlet    NUMBER NOT NULL,
  Szabad     NUMBER NOT NULL
*/

/* Az SQL*Plus escape karakter�t \(backslash)-re �ll�tjuk,
   mert & karakter is van sztringekben.
   Ezt vegye figyelembe, ha nem SQL*Plus-t haszn�l! */
SET ESCAPE \

INSERT INTO konyv VALUES (
  5, 'ISBN 963 19 0297 8', 
  'A r�mai jog t�rt�nete �s instit�ci�i', 
  'Nemzeti Tank�nyvkiad� Rt.', 1996, 
  T_Szerzok('Dr. F�ldi Andr�s', 'dr. Hamza G�bor'),
  20, 19
)
/

INSERT INTO konyv VALUES (
  10, 'ISBN 963 8453 09 5', 
  'A teljess�g fel�', 
  'Tericum Kiad�', 1995, 
  T_Szerzok('We�res S�ndor'),
  5, 4
)
/

INSERT INTO konyv VALUES (
  15, 'ISBN 963 9077 39 9', 
  'Piszkos Fred �s a t�bbiek', 
  'K�nyvkuck� Kiad�', 2000, 
  T_Szerzok('P. Howard', 'Rejt� Jen�'),
  5, 4
)
/

INSERT INTO konyv VALUES (
  20, 'ISBN 3-540-42206-4', 
  'ECOOP 2001 - Object-Oriented Programming', 
  'Springer-Verlag', 2001, 
  T_Szerzok('Jorgen Lindskov Knudsen (Ed.)', 'Gerthard Goos', 'Juris Hartmanis',
            'Jan van Leeuwen'),
  3, 2
)
/

INSERT INTO konyv VALUES (
  25, 'ISBN 963 03 9005 1', 
  'Java - start!', 
  'Logos 2000 Bt.', 1999, 
  T_Szerzok('V�g Csaba', 'dr. Juh�sz Istv�n'),
  10, 9
)
/

INSERT INTO konyv VALUES (
  30, 'ISBN 1-55860-456-1', 
  'SQL:1999 Understanding Relational Language Components', 
  'Morgan Kaufmann Publishers', 2002,
  T_Szerzok('Jim Melton', 'Alan R. Simon'),
  3, 1
)
/

INSERT INTO konyv VALUES (
  35, 'ISBN 0 521 27717 5', 
  'A critical introduction to twentieth-century American drama - Volume 2', 
  'Cambridge University Press', 1984, 
  T_Szerzok('C. W. E: Bigsby'),
  2, 0
)
/

INSERT INTO konyv VALUES (
  40, 'ISBN 0-393-95383-1', 
  'The Norton Anthology of American Literature - Second Edition - Volume 2', 
  'W. W. Norton \& Company, Inc.', 1985, 
  T_Szerzok('Nina Baym', 'Ronald Gottesman', 'Laurence B. Holland',
            'Francis Murphy', 'Hershel Parker', 'William H. Pritchard',
            'David Kalstone'),
  2, 1
)
/

INSERT INTO konyv VALUES (
  45, 'ISBN 963 05 6328 2', 
  'Matematikai zseblexikon', 
  'TypoTeX Kiad�', 1992, 
  T_Szerzok('Denkinger G�za', 'Scharnitzky Viktor', 'Tak�cs G�bor',
            'Tak�cs Mikl�s'),
  5, 3
)
/

INSERT INTO konyv VALUES (
  50, 'ISBN 963-9132-59-4', 
  'Matematikai K�zik�nyv', 
  'TypoTeX Kiad�', 2000, 
  T_Szerzok('I. N. Bronstejn', 'K. A. Szemangyajev', 'G. Musiol', 'H. M�hlig'),
  5, 3
)
/

/*
  Ugyfel:

  id                NUMBER PRIMARY KEY,
  Nev               VARCHAR2(100) NOT NULL,
  Anyja_neve        VARCHAR2(50) NOT NULL,
  Lakcim            VARCHAR2(100) NOT NULL,
  Tel_szam          VARCHAR2(20),
  Foglalkozas       VARCHAR2(50),
  Beiratkozas       DATE NOT NULL,
  Max_konyv         NUMBER DEFAULT 10 NOT NULL,
  Konyvek           T_Konyvek DEFAULT T_Konyvek()

  A nevek �s a c�mek kital�lt adatok, �gy a ir�ny�t�sz�mok,
  v�rosok, utcanevek a val�s�got nem t�kr�zik, �m a c�lnak 
  t�k�letesen megfelelnek.
*/

INSERT INTO ugyfel VALUES (
  5, 'Kov�cs J�nos', 'Szil�gyi Anna',
  '4242 Hajd�hadh�z, J�kai u. 3.', '06-52-123456',
  'K�z�piskolai tan�r', '00-M�J.  -24', 10, 
  T_Konyvek()
)
/

INSERT INTO ugyfel VALUES (
  10, 'Szab� M�t� Istv�n', 'Szegedi Zs�fia',
  '1234 Budapest, IX. Kossuth u. 51/b.', '06-1-1111222',
  NULL, '01-M�J.  -23', 10, 
  T_Konyvek(T_Tetel(30, '02-�PR.  -21'),
    T_Tetel(45, '02-�PR.  -21'),
    T_Tetel(50, '02-�PR.  -21'))
)
/

INSERT INTO ugyfel VALUES (
  15, 'J�zsef Istv�n', '�br�k Katalin',
  '4026 Debrecen, Bethlen u. 33. X./30.', '06-52-456654',
  'Programoz�', '01-SZEPT.-11', 5,
  T_Konyvek(T_Tetel(15, '02-JAN.  -22'),
    T_Tetel(20, '02-JAN.  -22'),
    T_Tetel(25, '02-�PR.  -10'),
    T_Tetel(45, '02-�PR.  -10'),
    T_Tetel(50, '02-�PR.  -10'))
)
/

INSERT INTO ugyfel VALUES (
  20, 'T�th L�szl�', 'Nagy M�ria',
  '1122 V�c, Pet�fi u. 15.', '06-42-154781',
  'Informatikus', '1996-�PR.  -01', 5,
  T_Konyvek(T_Tetel(30, '02-FEBR. -24'))
)
/

INSERT INTO ugyfel VALUES (
  25, 'Erdei Anita', 'Cserepes Ersz�bet',
  '2121 Hatvan, Sz�chenyi u. 4.', '06-12-447878',
  'Angol tan�r', '1997-DEC.  -05', 5,
  T_Konyvek(T_Tetel(35, '02-�PR.  -15'))
)
/

INSERT INTO ugyfel VALUES (
  30, 'Komor �gnes', 'T�th Eszter',
  '1327 Budapest V., Kossuth t�r 8.', NULL,
  'Egyetemi hallgat�', '00-J�N.  -11', 5,
  T_Konyvek(T_Tetel(5, '02-�PR.  -12'),
    T_Tetel(10, '02-M�RC. -12'))
)
/

INSERT INTO ugyfel VALUES (
  35, 'Jaripekka H�m�lainen', 'Pirkko Lehtovaara',
  '00500 Helsinki, Lintulahdenaukio 6. as 15.', '+358-9-1234567',
  NULL, '01-AUG.  -24', 5,
  T_Konyvek(T_Tetel(35, '02-M�RC. -18'),
    T_Tetel(40, '02-M�RC. -18'))
)
/

/* 
  Konzisztenss� tessz�k az adatb�zist a megfelel� k�lcs�nz�s
  bejegyz�sekkel.
*/

/* K�lcs�nz�: Szab� M�t� Istv�n */
INSERT INTO kolcsonzes VALUES (
  10, 30, '02-�PR.  -21', 0, NULL
)
/

INSERT INTO kolcsonzes VALUES (
  10, 45, '02-�PR.  -21', 0, NULL
)
/

INSERT INTO kolcsonzes VALUES (
  10, 50, '02-�PR.  -21', 0, NULL
)
/

/* K�lcs�nz�: J�zsef Istv�n */
INSERT INTO kolcsonzes VALUES (
  15, 15, '02-JAN.  -22', 2, NULL
)
/

INSERT INTO kolcsonzes VALUES (
  15, 20, '02-JAN.  -22', 2, NULL
)
/

INSERT INTO kolcsonzes VALUES (
  15, 25, '02-�PR.  -10', 0, NULL
)
/

INSERT INTO kolcsonzes VALUES (
  15, 45, '02-�PR.  -10', 0, NULL
)
/

INSERT INTO kolcsonzes VALUES (
  15, 50, '02-�PR.  -10', 0, NULL
)
/

/* K�lcs�nz�: T�th L�szl� */
INSERT INTO kolcsonzes VALUES (
  20, 30, '02-FEBR. -24', 2, NULL
)
/

/* K�lcs�nz�: Erdei Anita */
INSERT INTO kolcsonzes VALUES (
  25, 35, '02-�PR.  -15', 0, NULL
)
/

/* K�lcs�nz�: Komor �gnes */
INSERT INTO kolcsonzes VALUES (
  30, 5, '02-�PR.  -12', 0, NULL
)
/

INSERT INTO kolcsonzes VALUES (
  30, 10, '02-M�RC. -12', 1, NULL
)
/

/* K�lcs�nz�: Jaripekka H�m�lainen */
INSERT INTO kolcsonzes VALUES (
  35, 35, '02-M�RC. -18', 0, NULL
)
/

INSERT INTO kolcsonzes VALUES (
  35, 40, '02-M�RC. -18', 0, NULL
)
/
