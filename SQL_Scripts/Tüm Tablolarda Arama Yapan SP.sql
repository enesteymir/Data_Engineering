
CREATE PROC TumTablolardaArama
(@AranacakKelime NVARCHAR(100))
AS
BEGIN
    CREATE TABLE #Sonuclar
    (
        TabloAdi NVARCHAR(370),
        KolonAdi NVARCHAR(370),
        KolonDegeri NVARCHAR(3630)
    );
    SET NOCOUNT ON;
    DECLARE @TabloAdi NVARCHAR(256),
            @KolonAdi NVARCHAR(128),
            @AranacakKelime2 NVARCHAR(110);
    SET @TabloAdi = N'';
    SET @AranacakKelime2 = QUOTENAME('%' + @AranacakKelime + '%', '''');
    WHILE @TabloAdi IS NOT NULL
    BEGIN
        SET @KolonAdi = N'';
        SET @TabloAdi =
        (
            SELECT MIN(QUOTENAME(TABLE_SCHEMA) + '.' + QUOTENAME(TABLE_NAME))
            FROM INFORMATION_SCHEMA.TABLES
            WHERE TABLE_TYPE = 'BASE TABLE'
                  AND QUOTENAME(TABLE_SCHEMA) + '.' + QUOTENAME(TABLE_NAME) > @TabloAdi
                  AND OBJECTPROPERTY(OBJECT_ID(QUOTENAME(TABLE_SCHEMA) + '.' + QUOTENAME(TABLE_NAME)), 'IsMSShipped') = 0
        );
        WHILE (@TabloAdi IS NOT NULL) AND (@KolonAdi IS NOT NULL)
        BEGIN
            SET @KolonAdi =
            (
                SELECT MIN(QUOTENAME(COLUMN_NAME))
                FROM INFORMATION_SCHEMA.COLUMNS
                WHERE TABLE_SCHEMA = PARSENAME(@TabloAdi, 2)
                      AND TABLE_NAME = PARSENAME(@TabloAdi, 1)
                      AND DATA_TYPE IN ( 'char', 'varchar', 'nchar', 'nvarchar' )
                      AND QUOTENAME(COLUMN_NAME) > @KolonAdi
            );
            IF @KolonAdi IS NOT NULL
            BEGIN
                INSERT INTO #Sonuclar
                EXEC ('SELECT ''' + @TabloAdi + ''', ''' + @TabloAdi + '.' + @KolonAdi + ''', LEFT(' + @KolonAdi + ', 3630)
FROM '          + @TabloAdi + ' (NOLOCK) ' + ' WHERE ' + @KolonAdi + ' LIKE ' + @AranacakKelime2);
            END;
        END;
    END;
    SELECT *
    FROM #Sonuclar;
END;
 

--Kullanýmý
 
EXEC TumTablolardaArama @AranacakKelime = N'Yavuz';