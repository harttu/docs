CREATE TABLE Potilaat (
    PotilasID INT PRIMARY KEY,
    Etunimi VARCHAR(50),
    Sukunimi VARCHAR(50),
    Syntymäaika DATE,
    Osoite VARCHAR(100)
);

CREATE TABLE Lääkärit (
    LääkäriID INT PRIMARY KEY,
    Etunimi VARCHAR(50),
    Sukunimi VARCHAR(50),
    Erikoisala VARCHAR(50)
);

CREATE TABLE Diagnoosit (
    DiagnoosiID INT PRIMARY KEY,
    DiagnoosiKoodi VARCHAR(10),
    DiagnoosiKuvaus VARCHAR(255)
);

CREATE TABLE PotilasKäynnit (
    KäyntiID INT PRIMARY KEY,
    PotilasID INT,
    LääkäriID INT,
    DiagnoosiID INT,
    KäyntiPäivämäärä DATE,
    KäyntiKesto INT,
    FOREIGN KEY (PotilasID) REFERENCES Potilaat(PotilasID),
    FOREIGN KEY (LääkäriID) REFERENCES Lääkärit(LääkäriID),
    FOREIGN KEY (DiagnoosiID) REFERENCES Diagnoosit(DiagnoosiID)
);
-- Lisätään potilaita
INSERT INTO Potilaat VALUES (1, 'Matti', 'Meikäläinen', '1990-01-01', 'Katuosoite 1');
INSERT INTO Potilaat VALUES (2, 'Maija', 'Virtanen', '1985-05-05', 'Katuosoite 2');

-- Lisätään lääkäreitä
INSERT INTO Lääkärit VALUES (1, 'Laura', 'Lääkäri', 'Yleislääketiede');
INSERT INTO Lääkärit VALUES (2, 'Pekka', 'Kirurgi', 'Kirurgia');

-- Lisätään diagnooseja
INSERT INTO Diagnoosit VALUES (1, 'A00', 'Koleran');
INSERT INTO Diagnoosit VALUES (2, 'B00', 'Herpesviruksen');

-- Lisätään potilaskäyntejä
INSERT INTO PotilasKäynnit VALUES (1, 1, 1, 1, '2023-09-29', 30);
INSERT INTO PotilasKäynnit VALUES (2, 2, 2, 2, '2023-09-29', 45);

SELECT * FROM PotilasKäynnit

-- Lisätään lisää potilaita
INSERT INTO Potilaat VALUES (3, 'Liisa', 'Lahtinen', '1975-02-15', 'Katuosoite 3');
INSERT INTO Potilaat VALUES (4, 'Olli', 'Ollikainen', '1988-08-20', 'Katuosoite 4');
INSERT INTO Potilaat VALUES (5, 'Anna', 'Aaltonen', '2000-05-25', 'Katuosoite 5');

select * from Potilaat;

-- Lisätään lisää lääkäreitä
INSERT INTO Lääkärit VALUES (3, 'Sari', 'Sairaanhoitaja', 'Yleislääketiede');
INSERT INTO Lääkärit VALUES (4, 'Antti', 'Anestesia', 'Anestesiologia');

-- Lisätään lisää diagnooseja
INSERT INTO Diagnoosit VALUES (3, 'C00', 'Flunssa');
INSERT INTO Diagnoosit VALUES (4, 'D00', 'Murtuma');

select * from PotilasKäynnit;

-- Lisätään lisää potilaskäyntejä
INSERT INTO PotilasKäynnit VALUES (3, 3, 1, 3, '2023-09-15', 20);
INSERT INTO PotilasKäynnit VALUES (4, 4, 2, 4, '2023-09-10', 60);
INSERT INTO PotilasKäynnit VALUES (5, 5, 3, 3, '2023-08-29', 15);
INSERT INTO PotilasKäynnit VALUES (6, 1, 4, 4, '2023-09-05', 45);
INSERT INTO PotilasKäynnit VALUES (7, 2, 3, 1, '2023-08-30', 30);
INSERT INTO PotilasKäynnit VALUES (8, 4, 1, 2, '2023-09-20', 25);
INSERT INTO PotilasKäynnit VALUES (9, 5, 2, 3, '2023-09-22', 20);
INSERT INTO PotilasKäynnit VALUES (10, 3, 4, 4, '2023-09-01', 55);


SELECT 
    L.Etunimi || ' ' || L.Sukunimi AS Lääkäri,
    COUNT(DISTINCT PK.PotilasID) AS PotilaidenMäärä
FROM 
    PotilasKäynnit PK
JOIN 
    Lääkärit L ON PK.LääkäriID = L.LääkäriID
GROUP BY 
    L.Etunimi, L.Sukunimi
ORDER BY 
    PotilaidenMäärä DESC;



WITH FAKTA AS(
	SELECT (po.Etunimi || ' ' || po.Sukunimi) Potilas,
			lä.LääkäriID,
		   (lä.Etunimi || ' ' || lä.Sukunimi) Lääkäri,
		   di.DiagnoosiKuvaus,
		   KäyntiPäivämäärä,
		   EXTRACT('MONTH' FROM KäyntiPäivämäärä) as Kuukausi,
		   KäyntiKesto
	FROM PotilasKäynnit 
	inner join Potilaat po using(PotilasID)
	inner join Lääkärit lä using(LääkäriID)
	inner join Diagnoosit di using(DiagnoosiID)
	)	
-- Lasketaan käynnit kuukausittain Window Funktiolla
SELECT  Potilas,
EXTRACT('MONTH' FROM KäyntiPäivämäärä) as Kuukausi,
COUNT(Potilas) OVER (PARTITION BY Kuukausi) 
FROM FAKTA;

-- Lasketaan käynnit kuukausittain 
SELECT
Count(Potilas),
EXTRACT('MONTH' FROM KäyntiPäivämäärä) as Kuukausi
FROM FAKTA
GROUP BY Kuukausi;

	
-- Yleisimmät diagnoosit
SELECT DiagnoosiKuvaus, COUNT(DiagnoosiKuvaus) n
FROM FAKTA
GROUP BY DiagnoosiKuvaus
ORDER BY n DESC;
	
-- Potilaiden määrä per lääkäri
SELECT lääkäri, count(distinct(Potilas))
FROM FAKTA
GROUP BY lääkäri;
	
-- 
SELECT lääkäri, COUNT(lääkäri),AVG(käyntikesto) 
FROM FAKTA
GROUP BY lääkäri;
	

SELECT 
    KäyntiPäivämäärä,
    KäyntiKesto,
    SUM(KäyntiKesto) OVER (ORDER BY KäyntiPäivämäärä) AS KumulatiivinenKesto
FROM PotilasKäynnit;


