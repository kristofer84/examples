DECLARE @tid DATETIME = '2016-11-10 13:00' 
-- Missing Index Script 
-- Original Author: Pinal Dave  
SELECT TOP 25 
    dm_mid.database_id AS DatabaseID, 
    dm_migs.avg_user_impact*(dm_migs.user_seeks+dm_migs.user_scans) Avg_Estimated_Impact, 
    dm_migs.user_scans, 
    dm_migs.user_seeks, 
    dm_migs.avg_user_impact, 
    dm_migs.last_user_seek AS Last_User_Seek, 
    DB_NAME(dm_mid.database_ID) AS [Database], 
    OBJECT_NAME(dm_mid.OBJECT_ID, dm_mid.database_id) AS [TableName], 
    'CREATE INDEX [IX_' + OBJECT_NAME(dm_mid.OBJECT_ID,dm_mid.database_id) + '_' 
    + REPLACE(REPLACE(REPLACE(ISNULL(dm_mid.equality_columns,''),', ','_'),'[',''),']','')  
    + CASE 
        WHEN dm_mid.equality_columns IS NOT NULL AND dm_mid.inequality_columns IS NOT NULL 
        THEN '_' 
        ELSE '' 
    END 
    + REPLACE(REPLACE(REPLACE(ISNULL(dm_mid.inequality_columns,''),', ','_'),'[',''),']','') 
    + '] ON ' + dm_mid.statement 
    + ' (' + ISNULL (dm_mid.equality_columns,'') 
    + CASE 
        WHEN dm_mid.equality_columns IS NOT NULL AND dm_mid.inequality_columns IS NOT NULL 
        THEN ',' 
        ELSE '' 
    END 
    + ISNULL (dm_mid.inequality_columns, '') 
    + ')' 
    + ISNULL (' INCLUDE (' + dm_mid.included_columns + ')', '') AS Create_Statement 
FROM sys.dm_db_missing_index_groups dm_mig 
INNER JOIN sys.dm_db_missing_index_group_stats dm_migs 
ON dm_migs.group_handle = dm_mig.index_group_handle 
INNER JOIN sys.dm_db_missing_index_details dm_mid 
ON dm_mig.index_handle = dm_mid.index_handle 
--WHERE dm_mid.database_ID = DB_ID() 
WHERE @tid IS NULL OR (last_user_scan > @tid OR last_user_seek > @tid) 
ORDER BY Avg_Estimated_Impact DESC 
  
/* 
SELECT DB_NAME(stat.database_id), 
    --OBJECT_NAME(stat.object_id, stat.database_id), 
    stat.index_id, 
  
  
* FROM sys.dm_db_index_usage_stats stat 
INNER JOIN sys.indexes i ON stat.index_id = i.index_id AND i.object_id = stat.object_id 
WHERE stat.database_id NOT BETWEEN 1 AND 4 
    AND stat.last_user_lookup IS NULL 
    AND stat.last_user_scan IS NULL 
    AND stat.last_user_seek IS NULL 
SELECT *FROM sys.indexes NAME 
*/ 
  
 