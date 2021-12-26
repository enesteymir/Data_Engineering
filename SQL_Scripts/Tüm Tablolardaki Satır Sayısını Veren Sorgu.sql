
SELECT SC.name + '.' + T.name TableName, SUM(P.rows) RowCnt
FROM sys.tables T
INNER JOIN sys.partitions P ON P.object_id = T.object_id
INNER JOIN sys.schemas SC ON T.schema_id = SC.schema_id
WHERE T.is_ms_shipped = 0
AND P.index_id IN ( 1, 0 )
GROUP BY SC.name,T.name
ORDER BY SUM(P.rows) DESC;