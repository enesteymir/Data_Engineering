
CREATE  PROCEDURE GunHesapla
    @BaslangicTarihi DATETIME,
    @BitisTarihi DATETIME
AS
SET NOCOUNT ON;
 
DECLARE @GunFarki SMALLINT;
SET @GunFarki = DATEDIFF(dd, @BaslangicTarihi, @BitisTarihi);
 
 
WITH cteAralik (TarihAraligi)
AS (SELECT DATEADD(dd, DATEDIFF(dd, 0, @BitisTarihi) - @GunFarki, 0)
    UNION ALL
    SELECT DATEADD(dd, 1, TarihAraligi)
    FROM cteAralik
    WHERE DATEADD(dd, 1, TarihAraligi) < (@BitisTarihi ))
SELECT TarihAraligi
FROM cteAralik
OPTION (MAXRECURSION 3660);
GO
 
 
--Kullanýmý
 
EXEC GunHesapla @BaslangicTarihi = '2020-02-20 14:22:08.895'
   ,@BitisTarihi = '2020-02-25 14:22:08.895'