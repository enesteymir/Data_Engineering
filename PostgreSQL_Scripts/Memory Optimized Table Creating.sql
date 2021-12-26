USE KinetEcoDW;
GO

-- add  a memory optimized filegroup
ALTER DATABASE KinetEcoDW ADD FILEGROUP KinetEcoMOD CONTAINS memory_optimized_data
GO

-- give the filegroup a location on disk
ALTER DATABASE KinetEcoDW
        ADD FILE (
            NAME='KinetEcoMOD',
            FILENAME='C:\MemoryTemp\KinetEcoMOD')
        TO FILEGROUP KinetEcoMOD
GO

-- create a memory optimized fact table with a clustered columnstore index
CREATE TABLE Fact.Finance (
    FinanceID int IDENTITY (1,1) NOT NULL PRIMARY KEY NONCLUSTERED,
    DateKey int NOT NULL,
    Amount money NOT NULL,

    INDEX IX_CS_FactFinance CLUSTERED COLUMNSTORE
    )
    WITH (MEMORY_OPTIMIZED = ON);
GO