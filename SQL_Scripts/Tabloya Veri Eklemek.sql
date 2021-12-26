DROP TABLE IF EXISTS Sehirler


--Tablo olu�turulmas�
 
CREATE TABLE Sehirler
(
    Id INT IDENTITY(1, 1) PRIMARY KEY,
    SehirAd NVARCHAR(100)
);
 
--Tabloya veri eklenmesi
 
INSERT INTO Sehirler
(
    SehirAd
)
VALUES
('Konya'),
('�stanbul'),
('Artvin'),
('Bolu'),
('Bursa');
 
--Tablonun kontrol edilmesi
 
SELECT * FROM Sehirler s

