DROP TABLE IF EXISTS Sehirler


--Tablo oluþturulmasý
 
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
('Ýstanbul'),
('Artvin'),
('Bolu'),
('Bursa');
 
--Tablonun kontrol edilmesi
 
SELECT * FROM Sehirler s

