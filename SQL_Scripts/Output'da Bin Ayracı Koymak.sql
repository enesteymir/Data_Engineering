--SQL 'de output da bin ayrac� koymak

DECLARE @Miktar INT;
SET @Miktar = 65536;

SELECT FORMAT(@Miktar, '#,#') AS AyrilmisHali;