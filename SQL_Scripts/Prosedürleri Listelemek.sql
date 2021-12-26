SELECT sch.name AS [�ema Ad�],
obj.name AS [Stored Prosed�r Ad�],
obj.type AS [Tipi]
FROM sys.objects AS obj 
JOIN sys.sql_modules AS code ON code.object_id = obj.object_id
JOIN sys.schemas AS sch ON sch.schema_id = obj.schema_id
WHERE obj.type = 'P';

